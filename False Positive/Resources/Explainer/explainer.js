// Explainer page logic.
//
// 1. Typesets every `.math` element with KaTeX (bundled, so it works offline).
// 2. Exposes `FalsePositive.update(inputs)`, which the app calls after the
//    page loads to fill in worked examples with the user's own numbers.
//
// The formulas here must stay in sync with Model/DiagnosticTest.swift.

(function () {
  "use strict";

  const POPULATION = 100000;

  // ── Typesetting ──────────────────────────────────────────────

  function typeset(root) {
    root.querySelectorAll(".math:not(.rendered)").forEach((el) => {
      const tex = el.dataset.tex || el.textContent.trim();
      el.dataset.tex = tex;
      try {
        katex.render(tex, el, {
          displayMode: el.classList.contains("display"),
          throwOnError: false,
          output: "htmlAndMathml", // MathML keeps equations readable by VoiceOver
        });
        el.classList.add("rendered");
      } catch (e) {
        el.textContent = tex; // leave the source visible rather than nothing
      }
    });
    glueTrailingPunctuation(root);
    fitDisplays();
  }

  // Wrap an inline equation and the punctuation right after it ("P(B) ≠ 0,")
  // so the line can't break between them.
  function glueTrailingPunctuation(root) {
    root.querySelectorAll(".math:not(.display)").forEach((el) => {
      const next = el.nextSibling;
      if (!next || next.nodeType !== Node.TEXT_NODE) return;
      const match = next.textContent.match(/^[.,;:!?)]+/);
      if (!match || el.parentElement.classList.contains("nobr")) return;
      const wrapper = document.createElement("span");
      wrapper.className = "nobr";
      el.replaceWith(wrapper);
      wrapper.append(el, match[0]);
      next.textContent = next.textContent.slice(match[0].length);
    });
  }

  // Shrink wide display equations to fit the card (down to 70%) before
  // falling back to horizontal scrolling.
  function fitDisplays() {
    document.querySelectorAll(".math.display.rendered").forEach((el) => {
      el.style.fontSize = "";
      const padding = 24;
      const available = el.clientWidth - padding;
      const needed = el.scrollWidth - padding;
      if (needed > available + 1) {
        el.style.fontSize = Math.max(0.7, available / needed).toFixed(3) + "em";
      }
    });
  }

  // ── Formatting ───────────────────────────────────────────────

  const percentFormat = new Intl.NumberFormat(undefined, {
    style: "percent",
    maximumFractionDigits: 2,
  });
  const countFormat = new Intl.NumberFormat();

  // Numbers inside equations use a fixed "." decimal, as is usual in math.
  function num(x) {
    return x.toLocaleString("en-US", { maximumSignificantDigits: 4, useGrouping: false });
  }
  function pctNumber(x) {
    return (x * 100).toLocaleString("en-US", { maximumFractionDigits: 2, useGrouping: false });
  }
  function pct(x) {
    return pctNumber(x) + "\\%";
  }
  // Floating-point noise (0.0095 + 0.0495 = 0.059000000000000004) shouldn't
  // turn an exact result into an approximation.
  function same(a, b) {
    return Math.abs(a - b) <= 1e-12 * Math.max(1, Math.abs(b));
  }
  // "=" when the shown number is exact, "≈" when it has been rounded.
  function rel(x) {
    return same(Number(num(x)), x) ? "=" : "\\approx";
  }
  function relPct(x) {
    return same(Number(pctNumber(x)), x * 100) ? "=" : "\\approx";
  }

  // ── Statistics (mirrors DiagnosticTest) ──────────────────────

  function analyze(prev, sens, spec) {
    const pPositive = sens * prev + (1 - spec) * (1 - prev);
    const pNegative = (1 - sens) * prev + spec * (1 - prev);
    const ppv = pPositive > 0 ? (sens * prev) / pPositive : null;
    const npv = pNegative > 0 ? (spec * (1 - prev)) / pNegative : null;

    const sick = Math.round(POPULATION * prev);
    const healthy = POPULATION - sick;
    const tp = Math.round(sick * sens);
    const tn = Math.round(healthy * spec);

    return {
      prev, sens, spec, pPositive, pNegative, ppv, npv,
      fdr: ppv === null ? null : 1 - ppv,
      for: npv === null ? null : 1 - npv,
      counts: { tp, fn: sick - tp, tn, fp: healthy - tn },
    };
  }

  // ── Worked examples ──────────────────────────────────────────

  function aligned(lines) {
    return "\\begin{aligned}" + lines.join(" \\\\[4pt] ") + "\\end{aligned}";
  }

  const worked = {
    prevalence: (s) => ({
      tex: `P(D) = ${num(s.prev)}, \\quad P(D') = 1 - ${num(s.prev)} ${rel(1 - s.prev)} ${num(1 - s.prev)}`,
      note: `Out of ${countFormat.format(POPULATION)} people, about ${countFormat.format(s.counts.tp + s.counts.fn)} have the condition.`,
    }),

    sensitivity: (s) => ({
      tex: `P(T \\mid D) = ${num(s.sens)}, \\quad P(T' \\mid D) = 1 - ${num(s.sens)} ${rel(1 - s.sens)} ${num(1 - s.sens)}`,
      note: `So ${percentFormat.format(1 - s.sens)} of people who have the condition would be missed (false negatives).`,
    }),

    specificity: (s) => ({
      tex: `P(T' \\mid D') = ${num(s.spec)}, \\quad P(T \\mid D') = 1 - ${num(s.spec)} ${rel(1 - s.spec)} ${num(1 - s.spec)}`,
      note: `So ${percentFormat.format(1 - s.spec)} of people without the condition would get a false alarm (false positives).`,
    }),

    pPositive: (s) => {
      const a = s.sens * s.prev, b = (1 - s.spec) * (1 - s.prev);
      return {
        tex: aligned([
          `P(T) &= (${num(s.sens)})(${num(s.prev)}) + (${num(1 - s.spec)})(${num(1 - s.prev)})`,
          `&${rel(a)} ${num(a)} + ${num(b)}`,
          `&${rel(s.pPositive)} ${num(s.pPositive)} ${relPct(s.pPositive)} ${pct(s.pPositive)}`,
        ]),
      };
    },

    pNegative: (s) => {
      const a = s.spec * (1 - s.prev), b = (1 - s.sens) * s.prev;
      return {
        tex: aligned([
          `P(T') &= (${num(s.spec)})(${num(1 - s.prev)}) + (${num(1 - s.sens)})(${num(s.prev)})`,
          `&${rel(a)} ${num(a)} + ${num(b)}`,
          `&${rel(s.pNegative)} ${num(s.pNegative)} ${relPct(s.pNegative)} ${pct(s.pNegative)}`,
        ]),
      };
    },

    ppv: (s) => {
      if (s.ppv === null) return { note: "With these numbers nobody tests positive, so PPV is undefined." };
      const tp = s.sens * s.prev;
      return {
        tex: `\\text{PPV} = \\frac{(${num(s.sens)})(${num(s.prev)})}{${num(s.pPositive)}} ${rel(tp)} \\frac{${num(tp)}}{${num(s.pPositive)}} ${rel(s.ppv)} ${num(s.ppv)} ${relPct(s.ppv)} ${pct(s.ppv)}`,
        note: `Of the ${countFormat.format(s.counts.tp + s.counts.fp)} people who test positive, only ${countFormat.format(s.counts.tp)} actually have the condition.`,
      };
    },

    fdr: (s) => s.fdr === null
      ? { note: "With these numbers nobody tests positive, so FDR is undefined." }
      : { tex: `\\text{FDR} = 1 - ${num(s.ppv)} ${rel(s.fdr)} ${num(s.fdr)} ${relPct(s.fdr)} ${pct(s.fdr)}` },

    npv: (s) => {
      if (s.npv === null) return { note: "With these numbers nobody tests negative, so NPV is undefined." };
      const tn = s.spec * (1 - s.prev);
      return {
        tex: `\\text{NPV} = \\frac{(${num(s.spec)})(${num(1 - s.prev)})}{${num(s.pNegative)}} ${rel(tn)} \\frac{${num(tn)}}{${num(s.pNegative)}} ${rel(s.npv)} ${num(s.npv)} ${relPct(s.npv)} ${pct(s.npv)}`,
        note: `Of the ${countFormat.format(s.counts.tn + s.counts.fn)} people who test negative, ${countFormat.format(s.counts.tn)} are actually clear.`,
      };
    },

    for: (s) => s.for === null
      ? { note: "With these numbers nobody tests negative, so FOR is undefined." }
      : { tex: `\\text{FOR} = 1 - ${num(s.npv)} ${rel(s.for)} ${num(s.for)} ${relPct(s.for)} ${pct(s.for)}` },
  };

  function renderWorked(stats) {
    document.querySelectorAll(".worked[data-calc]").forEach((el) => {
      const result = stats ? worked[el.dataset.calc](stats) : null;
      el.replaceChildren();
      if (!result) return;

      const label = document.createElement("p");
      label.className = "label";
      label.textContent = "With your numbers";
      el.append(label);

      if (result.tex) {
        const math = document.createElement("div");
        math.className = "math display";
        math.textContent = result.tex;
        el.append(math);
      }
      if (result.note) {
        const note = document.createElement("p");
        note.className = "note muted small";
        note.textContent = result.note;
        el.append(note);
      }
    });
  }

  // ── Public API ───────────────────────────────────────────────

  function setValue(key, text) {
    document.querySelectorAll(`[data-value="${key}"]`).forEach((el) => { el.textContent = text; });
  }

  /**
   * Fill the page with the user's inputs.
   * @param {{prevalence: number, sensitivity: number, specificity: number} | null} inputs
   *   Fractions in 0...1, or null if the calculator inputs are incomplete or invalid.
   */
  function update(inputs) {
    const valid = inputs && ["prevalence", "sensitivity", "specificity"].every(
      (k) => typeof inputs[k] === "number" && inputs[k] >= 0 && inputs[k] <= 1
    );
    const stats = valid ? analyze(inputs.prevalence, inputs.sensitivity, inputs.specificity) : null;

    document.body.classList.toggle("has-values", !!stats);
    setValue("population-size", countFormat.format(POPULATION));

    if (stats) {
      setValue("prevalence", percentFormat.format(stats.prev));
      setValue("sensitivity", percentFormat.format(stats.sens));
      setValue("specificity", percentFormat.format(stats.spec));
      setValue("ppv", stats.ppv === null ? "—" : percentFormat.format(stats.ppv));
      for (const key of ["tp", "fp", "fn", "tn"]) {
        setValue(key, countFormat.format(stats.counts[key]));
      }
      setValue("matrix-note", "people out of " + countFormat.format(POPULATION));
    } else {
      for (const key of ["tp", "fp", "fn", "tn", "matrix-note"]) setValue(key, "");
    }

    renderWorked(stats);
    typeset(document);
  }

  window.FalsePositive = { update };

  typeset(document);
  window.addEventListener("resize", fitDisplays);
})();

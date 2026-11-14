# False Positive

An iOS calculator that shows why a positive result on an accurate medical test can still be more likely wrong than right.

Enter the **prevalence** of a condition, plus the test's **sensitivity** and **specificity**. The app uses Bayes' theorem to show:

- **Probabilities**: P(+), P(−), positive and negative predictive value (PPV/NPV), false discovery rate (FDR), and false omission rate (FOR)
- **Actuals**: the expected true and false positives and negatives when 100,000 people are tested

The info button opens an explainer that walks through the math behind each number, with worked examples that use your inputs.

## Requirements

- Xcode 26 or later
- iOS / iPadOS 17.0 or later (iPhone and iPad)

## Project layout

| Path | Contents |
| --- | --- |
| `False Positive/Model/DiagnosticTest.swift` | All of the statistics, as a pure, tested value type |
| `False Positive/Views/` | SwiftUI screens (calculator, result views, info and help sheets) |
| `False Positive/Resources/Explainer/` | The explainer page (HTML, CSS, JS) and a bundled copy of [KaTeX](https://katex.org) 0.16.11 for typesetting equations |
| `FalsePositiveTests/` | Unit tests (Swift Testing) |
| `Docs/` | The original 2020 R Markdown write-up and PDF |
| `Marketing/` | Original 2020 App Store screenshots and source artwork |

The project uses Xcode's synchronized folders, so any file you add under `False Positive/` or `FalsePositiveTests/` is picked up automatically, with no need to edit the project file.

## Building and testing

Open `False Positive.xcodeproj` in Xcode and run the **False Positive** scheme. Or, from the command line:

```sh
xcodebuild test -project "False Positive.xcodeproj" -scheme "False Positive" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## Updating the explainer

Edit the files in `False Positive/Resources/Explainer/` directly:

- `explainer.html` holds the text. Write equations as TeX inside an element with class `math` (add `display` for a centered, block equation). Escape `&` as `&amp;`.
- `explainer.css` holds the styling, which mirrors the app's colors and cards.
- `explainer.js` typesets the equations and fills in the worked examples. The app calls `FalsePositive.update({prevalence, sensitivity, specificity})` with fractions from 0 to 1, or `null` when the inputs are incomplete. Its formulas must stay in sync with `Model/DiagnosticTest.swift`.

Everything is bundled, so the page works offline. Xcode copies the files flat into the app bundle, so the stylesheet refers to the KaTeX fonts by file name alone.

© App Factorial LLC

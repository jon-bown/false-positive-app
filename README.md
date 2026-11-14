# False Positive

An iOS calculator that shows why a positive result on an accurate medical test can still be more likely wrong than right.

Enter the **prevalence** of a condition, plus the test's **sensitivity** and **specificity**. The app uses Bayes' theorem to show:

- **Probabilities**: P(+), P(−), positive and negative predictive value (PPV/NPV), false discovery rate (FDR), and false omission rate (FOR)
- **Actuals**: the expected true and false positives and negatives when 100,000 people are tested

The info button opens an explainer covering the math behind each number.

## Requirements

- Xcode 26 or later
- iOS / iPadOS 17.0 or later (iPhone and iPad)

## Project layout

| Path | Contents |
| --- | --- |
| `False Positive/Model/DiagnosticTest.swift` | All of the statistics, as a pure, tested value type |
| `False Positive/Views/` | SwiftUI screens (calculator, result views, info and help sheets) |
| `False Positive/Resources/index.html` | The bundled explainer page, knitted from `Docs/Documentation.Rmd` |
| `FalsePositiveTests/` | Unit tests (Swift Testing) |
| `Docs/` | R Markdown source and PDF of the explainer |
| `Marketing/` | Original 2020 App Store screenshots and source artwork |

The project uses Xcode's synchronized folders, so any file you add under `False Positive/` or `FalsePositiveTests/` is picked up automatically, with no need to edit the project file.

## Building and testing

Open `False Positive.xcodeproj` in Xcode and run the **False Positive** scheme. Or, from the command line:

```sh
xcodebuild test -project "False Positive.xcodeproj" -scheme "False Positive" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro"
```

## Updating the explainer

Edit `Docs/Documentation.Rmd`, knit it to HTML in RStudio, and copy the output to `False Positive/Resources/index.html`.

© App Factorial LLC

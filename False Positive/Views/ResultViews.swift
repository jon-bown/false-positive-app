//
//  ResultViews.swift
//  False Positive
//
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI

// MARK: - Summary

/// A plain-language sentence that explains the headline result.
struct SummaryCard: View {
    let test: DiagnosticTest

    var body: some View {
        let population = test.population()
        VStack(alignment: .leading, spacing: 8) {
            Text("If you test positive")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if let ppv = test.positivePredictiveValue {
                Text("there's a **\(ppv.percentText)** chance you actually have the condition.")
                    .font(.title3)
                Text("Of \(population.total.countText) people tested, \(population.testedPositive.countText) test positive, but only \(population.truePositives.countText) of them are sick.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("With these numbers, nobody tests positive.")
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Probabilities

struct ProbabilityGrid: View {
    let test: DiagnosticTest?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatTile(symbol: "P(+)", value: test?.probabilityPositive,
                     caption: "Chance a random person tests positive")
            StatTile(symbol: "P(−)", value: test?.probabilityNegative,
                     caption: "Chance a random person tests negative")
            StatTile(symbol: "PPV", value: test?.positivePredictiveValue,
                     caption: "If positive, chance you have it", highlight: true)
            StatTile(symbol: "NPV", value: test?.negativePredictiveValue,
                     caption: "If negative, chance you don't")
            StatTile(symbol: "FDR", value: test?.falseDiscoveryRate,
                     caption: "Positive results that are wrong")
            StatTile(symbol: "FOR", value: test?.falseOmissionRate,
                     caption: "Negative results that are wrong")
        }
    }
}

struct StatTile: View {
    let symbol: String
    let value: Double?
    let caption: LocalizedStringKey
    var highlight = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(highlight ? Color.accentColor : .secondary)
            Text(value?.percentText ?? "—")
                .font(.title.monospacedDigit().weight(.bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .contentTransition(.numericText())
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .cardStyle(highlighted: highlight)
        .animation(.snappy, value: value)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Population ("Actuals")

struct PopulationTable: View {
    let breakdown: PopulationBreakdown?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Out of \((breakdown?.total ?? PopulationBreakdown.defaultSize).countText) people tested")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Grid(alignment: .trailing, horizontalSpacing: 12, verticalSpacing: 10) {
                GridRow {
                    Text("")
                    header("Sick")
                    header("Healthy")
                    header("Total")
                }
                Divider().gridCellUnsizedAxes(.horizontal)
                GridRow {
                    rowLabel("Test +")
                    cell(breakdown?.truePositives, label: "True positives", tint: .green)
                    cell(breakdown?.falsePositives, label: "False positives", tint: .red)
                    cell(breakdown?.testedPositive, bold: true)
                }
                GridRow {
                    rowLabel("Test −")
                    cell(breakdown?.falseNegatives, label: "False negatives", tint: .red)
                    cell(breakdown?.trueNegatives, label: "True negatives", tint: .green)
                    cell(breakdown?.testedNegative, bold: true)
                }
                Divider().gridCellUnsizedAxes(.horizontal)
                GridRow {
                    rowLabel("Total")
                    cell(breakdown?.sick, bold: true)
                    cell(breakdown?.healthy, bold: true)
                    cell(breakdown?.total, bold: true)
                }
            }
            .font(.body.monospacedDigit())

            HStack(spacing: 16) {
                Label("Correct result", systemImage: "circle.fill").foregroundStyle(.green)
                Label("Wrong result", systemImage: "circle.fill").foregroundStyle(.red)
            }
            .labelStyle(LegendLabelStyle())
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func header(_ text: LocalizedStringKey) -> some View {
        Text(text).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
    }

    private func rowLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .gridColumnAlignment(.leading)
    }

    @ViewBuilder
    private func cell(_ value: Int?, label: LocalizedStringKey? = nil, tint: Color? = nil, bold: Bool = false) -> some View {
        let text = Text(value?.countText ?? "—")
            .fontWeight(bold ? .semibold : .regular)
            .foregroundStyle(tint ?? .primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .contentTransition(.numericText())
            .animation(.snappy, value: value)
        if let label {
            text.accessibilityLabel(Text(label))
                .accessibilityValue(Text(value?.countText ?? "unavailable"))
        } else {
            text
        }
    }
}

private struct LegendLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 8))
            configuration.title.foregroundStyle(.secondary)
        }
    }
}

// MARK: - Formatting

extension Double {
    var percentText: String {
        formatted(.percent.precision(.fractionLength(0...2)))
    }
}

extension Int {
    var countText: String { formatted(.number) }
}

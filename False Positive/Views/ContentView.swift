//
//  ContentView.swift
//  False Positive
//
//  Created by Jonathan Bown on 6/24/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    enum Field: Hashable { case prevalence, sensitivity, specificity }
    enum ResultMode: String, CaseIterable, Identifiable {
        case probabilities = "Probabilities"
        case population = "Actuals"
        var id: Self { self }
    }

    // Percentages as entered by the user (0–100). Defaults show the classic
    // "rare disease, good test" case where most positives are still false.
    @State private var prevalence: Double? = 1
    @State private var sensitivity: Double? = 95
    @State private var specificity: Double? = 95

    @State private var mode: ResultMode = .probabilities
    @State private var showingInfo = false
    @State private var showingHelp = false
    @FocusState private var focusedField: Field?

    private var test: DiagnosticTest? {
        guard let prevalence, let sensitivity, let specificity else { return nil }
        return DiagnosticTest(
            prevalencePercent: prevalence,
            sensitivityPercent: sensitivity,
            specificityPercent: specificity
        )
    }

    private var hasOutOfRangeInput: Bool {
        [prevalence, sensitivity, specificity].contains { value in
            value.map { !(0...100).contains($0) } ?? false
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    inputCard
                    if let test {
                        SummaryCard(test: test)
                    }
                    Picker("Results", selection: $mode) {
                        ForEach(ResultMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    switch mode {
                    case .probabilities:
                        ProbabilityGrid(test: test)
                    case .population:
                        PopulationTable(breakdown: test?.population())
                    }
                }
                .padding()
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
                .animation(.snappy, value: mode)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.appBackground).ignoresSafeArea())
            .navigationTitle("False Positive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Learn the math", systemImage: "info.circle") { showingInfo = true }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("How to use", systemImage: "questionmark.circle") { showingHelp = true }
                }
            }
            // A hand-rolled keyboard accessory bar. SwiftUI's built-in
            // `.toolbar { ToolbarItemGroup(placement: .keyboard) }` logs
            // "Invalid frame dimension (negative or non-finite)" on iOS 27
            // every time the keyboard appears, whatever its contents.
            // The bottom safe area includes the keyboard, so this sits on top of it.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if focusedField != nil {
                    keyboardBar
                        .transition(.opacity)
                }
            }
            .sheet(isPresented: $showingInfo) { InfoSheet() }
            .sheet(isPresented: $showingHelp) { HelpSheet() }
        }
    }

    private var inputCard: some View {
        VStack(spacing: 16) {
            PercentField(
                title: "Prevalence",
                caption: "Share of people who have the condition",
                value: $prevalence, focus: $focusedField, field: .prevalence
            )
            Divider()
            PercentField(
                title: "Sensitivity",
                caption: "Sick people the test correctly flags",
                value: $sensitivity, focus: $focusedField, field: .sensitivity
            )
            Divider()
            PercentField(
                title: "Specificity",
                caption: "Healthy people the test correctly clears",
                value: $specificity, focus: $focusedField, field: .specificity
            )
            if hasOutOfRangeInput {
                Label("Enter percentages between 0 and 100.", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .cardStyle()
        .animation(.default, value: hasOutOfRangeInput)
    }

    private var keyboardBar: some View {
        HStack(spacing: 20) {
            Button("Previous field", systemImage: "chevron.up") { moveFocus(by: -1) }
                .disabled(focusedField == .prevalence)
            Button("Next field", systemImage: "chevron.down") { moveFocus(by: 1) }
                .disabled(focusedField == .specificity)
            Spacer()
            Button("Done") { focusedField = nil }
                .fontWeight(.semibold)
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.medium))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }

    private func moveFocus(by offset: Int) {
        let order: [Field] = [.prevalence, .sensitivity, .specificity]
        guard let current = focusedField, let index = order.firstIndex(of: current) else { return }
        let next = index + offset
        if order.indices.contains(next) { focusedField = order[next] }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

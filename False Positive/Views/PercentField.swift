//
//  PercentField.swift
//  False Positive
//
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI

/// A labeled numeric entry row for a percentage between 0 and 100.
///
/// The bound value updates on every keystroke so results stay live while typing.
/// It is `nil` when the field is empty or can't be parsed.
struct PercentField<Field: Hashable>: View {
    let title: LocalizedStringKey
    let caption: LocalizedStringKey
    @Binding var value: Double?
    let focus: FocusState<Field?>.Binding
    let field: Field

    @State private var text = ""

    private var isInvalid: Bool {
        guard let value else { return !text.isEmpty }
        return !(0...100).contains(value)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            HStack(spacing: 2) {
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused(focus, equals: field)
                    .accessibilityLabel(Text(title))
                    .accessibilityValue(Text(text.isEmpty ? "empty" : "\(text) percent"))
                Text("%")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .font(.title2.monospacedDigit().weight(.semibold))
            .frame(width: 110)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.black.opacity(0.25), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            }
            .contentShape(.rect)
            .onTapGesture { focus.wrappedValue = field }
        }
        .onAppear { text = Self.format(value) }
        .onChange(of: text) { _, newText in
            let parsed = Self.parse(newText)
            if parsed != value { value = parsed }
        }
        .onChange(of: value) { _, newValue in
            // Only overwrite the text when the value changed from outside
            // (e.g. a preset), so we don't fight the user's typing.
            if Self.parse(text) != newValue { text = Self.format(newValue) }
        }
    }

    private var borderColor: Color {
        if isInvalid { return .red }
        if focus.wrappedValue == field { return .accentColor }
        return .white.opacity(0.12)
    }

    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return try? Double(trimmed, format: .number)
    }

    static func format(_ value: Double?) -> String {
        guard let value else { return "" }
        return value.formatted(.number.precision(.fractionLength(0...4)).grouping(.never))
    }
}

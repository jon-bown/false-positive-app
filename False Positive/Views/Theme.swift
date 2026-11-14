//
//  Theme.swift
//  False Positive
//
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI

// Colors live in Assets.xcassets (AccentColor, AppBackground) so the launch
// screen can use them too. Xcode generates `Color(.appBackground)` etc.

private struct CardStyle: ViewModifier {
    var highlighted: Bool

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white.opacity(0.06), in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(highlighted ? Color.accentColor.opacity(0.8) : .white.opacity(0.08), lineWidth: highlighted ? 1.5 : 1)
            }
    }
}

extension View {
    func cardStyle(highlighted: Bool = false) -> some View {
        modifier(CardStyle(highlighted: highlighted))
    }
}

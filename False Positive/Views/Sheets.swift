//
//  Sheets.swift
//  False Positive
//
//  Created by Jonathan Bown on 7/15/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI
import WebKit

/// The bundled explainer page ("The Probability Behind Medical Testing"),
/// generated from `Docs/Documentation.Rmd`.
struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            BundledWebView(resource: "index")
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("The Math")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Enter the known or estimated prevalence of a disease or condition being tested for. Then enter the test's sensitivity and specificity to see how the probabilities change. Results update as you type.")
                    Text("**Probabilities** shows the statistics described on the info page. Tap the info button to learn more about these quantities and how to interpret them.")
                    Text("**Actuals** applies those statistics to a population of 100,000 people, showing how many results would be true or false positives and negatives.")
                    Text("For realistic results, try a prevalence below 50% and sensitivity and specificity between 80% and 99%.")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        Text("© App Factorial LLC")
                        Text(versionText)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                }
                .padding()
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("How to Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// Displays an HTML file from the app bundle.
struct BundledWebView: UIViewRepresentable {
    let resource: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        if let url = Bundle.main.url(forResource: resource, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            webView.loadHTMLString("<p style='font-family:-apple-system'>Content unavailable.</p>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

//
//  Sheets.swift
//  False Positive
//
//  Created by Jonathan Bown on 7/15/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI
import WebKit

/// The explainer page ("The Probability Behind Medical Testing").
///
/// It's a bundled web page (`Resources/Explainer`) so the equations can be
/// typeset with KaTeX. It's styled to match the app, and worked examples are
/// filled in with the user's current inputs.
struct InfoSheet: View {
    let test: DiagnosticTest?
    @Environment(\.dismiss) private var dismiss
    @State private var isReady = false

    var body: some View {
        NavigationStack {
            ExplainerWebView(test: test) { isReady = true }
                .ignoresSafeArea(edges: .bottom)
                .background(Color(.appBackground).ignoresSafeArea())
                .overlay {
                    if !isReady {
                        ProgressView()
                            .controlSize(.large)
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: isReady)
                .navigationTitle("How It Works")
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

/// Shows the bundled explainer page and passes it the calculator's inputs.
struct ExplainerWebView: UIViewRepresentable {
    let test: DiagnosticTest?
    /// Called once the page has loaded and shows the user's inputs.
    var onReady: @MainActor () -> Void = {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        // Stay opaque (a transparent WKWebView on iOS 27 doesn't paint until it
        // scrolls) but match the app background, and keep the view invisible
        // until the page has loaded and received the inputs, so there's no
        // white flash or half-filled page.
        let background = UIColor(resource: .appBackground)
        webView.backgroundColor = background
        webView.underPageBackgroundColor = background
        webView.scrollView.backgroundColor = background
        webView.alpha = 0
        webView.navigationDelegate = context.coordinator
        context.coordinator.test = test
        context.coordinator.onReady = onReady

        if let url = Bundle.main.url(forResource: "explainer", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onReady = onReady
        guard context.coordinator.test != test else { return }
        context.coordinator.test = test
        context.coordinator.pushInputs(to: webView)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        var test: DiagnosticTest?
        var onReady: @MainActor () -> Void = {}
        private var isLoaded = false

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            pushInputs(to: webView) { [onReady] in
                UIView.animate(withDuration: 0.2) { webView.alpha = 1 }
                onReady()
            }
        }

        /// Calls `FalsePositive.update(inputs)` in the page. Values are passed as
        /// arguments rather than spliced into the script source.
        func pushInputs(to webView: WKWebView, completion: (@MainActor () -> Void)? = nil) {
            guard isLoaded else { return }
            let inputs: Any = test.map {
                ["prevalence": $0.prevalence, "sensitivity": $0.sensitivity, "specificity": $0.specificity]
            } ?? NSNull()
            webView.callAsyncJavaScript(
                "window.FalsePositive && window.FalsePositive.update(inputs)",
                arguments: ["inputs": inputs],
                in: nil,
                in: .page
            ) { _ in completion?() }
        }

        /// Only the bundled page (and in-page anchor links) may load in the web view.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            navigationAction.request.url?.isFileURL == true ? .allow : .cancel
        }
    }
}

//
//  DiagnosticTest.swift
//  False Positive
//
//  Created by Jonathan Bown on 6/24/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import Foundation

/// A screening test applied to a population, described by the three numbers
/// the user enters. All derived statistics follow from Bayes' theorem.
///
/// Values are stored as fractions in `0...1`.
struct DiagnosticTest: Equatable, Sendable {
    /// P(D): fraction of the population that has the condition.
    let prevalence: Double
    /// P(T | D): fraction of sick people the test correctly flags.
    let sensitivity: Double
    /// P(T' | D'): fraction of healthy people the test correctly clears.
    let specificity: Double

    /// Creates a test from fractions in `0...1`. Returns `nil` if any value is
    /// out of range or not a finite number.
    init?(prevalence: Double, sensitivity: Double, specificity: Double) {
        let range = 0.0...1.0
        guard range.contains(prevalence),
              range.contains(sensitivity),
              range.contains(specificity) else { return nil }
        self.prevalence = prevalence
        self.sensitivity = sensitivity
        self.specificity = specificity
    }

    /// Creates a test from percentages in `0...100`, as entered in the UI.
    init?(prevalencePercent: Double, sensitivityPercent: Double, specificityPercent: Double) {
        self.init(
            prevalence: prevalencePercent / 100,
            sensitivity: sensitivityPercent / 100,
            specificity: specificityPercent / 100
        )
    }

    // MARK: - Probabilities

    /// P(T): probability that a randomly chosen person tests positive.
    var probabilityPositive: Double {
        sensitivity * prevalence + (1 - specificity) * (1 - prevalence)
    }

    /// P(T'): probability that a randomly chosen person tests negative.
    var probabilityNegative: Double {
        (1 - sensitivity) * prevalence + specificity * (1 - prevalence)
    }

    /// PPV = P(D | T): chance a person who tests positive actually has the condition.
    /// `nil` when nobody can test positive, so the ratio is undefined.
    var positivePredictiveValue: Double? {
        let p = probabilityPositive
        return p > 0 ? sensitivity * prevalence / p : nil
    }

    /// NPV = P(D' | T'): chance a person who tests negative is actually healthy.
    /// `nil` when nobody can test negative, so the ratio is undefined.
    var negativePredictiveValue: Double? {
        let p = probabilityNegative
        return p > 0 ? specificity * (1 - prevalence) / p : nil
    }

    /// FDR = P(D' | T) = 1 − PPV: share of positive results that are wrong.
    var falseDiscoveryRate: Double? {
        positivePredictiveValue.map { 1 - $0 }
    }

    /// FOR = P(D | T') = 1 − NPV: share of negative results that are wrong.
    var falseOmissionRate: Double? {
        negativePredictiveValue.map { 1 - $0 }
    }

    // MARK: - Population

    /// Expected outcomes when the test is given to `size` people.
    ///
    /// Counts are rounded so that every row and column adds up exactly to its total.
    func population(of size: Int = PopulationBreakdown.defaultSize) -> PopulationBreakdown {
        let sick = Int((Double(size) * prevalence).rounded())
        let healthy = size - sick
        let truePositives = Int((Double(sick) * sensitivity).rounded())
        let trueNegatives = Int((Double(healthy) * specificity).rounded())
        return PopulationBreakdown(
            total: size,
            sick: sick,
            healthy: healthy,
            truePositives: truePositives,
            falseNegatives: sick - truePositives,
            trueNegatives: trueNegatives,
            falsePositives: healthy - trueNegatives
        )
    }
}

/// A 2×2 confusion matrix of expected test outcomes for a population.
struct PopulationBreakdown: Equatable, Sendable {
    static let defaultSize = 100_000

    let total: Int
    let sick: Int
    let healthy: Int
    let truePositives: Int
    let falseNegatives: Int
    let trueNegatives: Int
    let falsePositives: Int

    var testedPositive: Int { truePositives + falsePositives }
    var testedNegative: Int { trueNegatives + falseNegatives }
}

//
//  DiagnosticTestTests.swift
//  FalsePositiveTests
//
//  Copyright © 2020 App Factorial. All rights reserved.
//

import Testing
@testable import False_Positive

struct DiagnosticTestTests {
    private func approx(_ a: Double?, _ b: Double, tolerance: Double = 1e-9) -> Bool {
        guard let a else { return false }
        return abs(a - b) <= tolerance
    }

    @Test func classicRareDiseaseExample() throws {
        // 1% prevalence, 95% sensitivity, 95% specificity → PPV ≈ 16.1%
        let test = try #require(DiagnosticTest(prevalencePercent: 1, sensitivityPercent: 95, specificityPercent: 95))
        #expect(approx(test.probabilityPositive, 0.059))
        #expect(approx(test.probabilityNegative, 0.941))
        #expect(approx(test.positivePredictiveValue, 0.0095 / 0.059))
        #expect(approx(test.negativePredictiveValue, 0.9405 / 0.941))
        #expect(approx(test.falseDiscoveryRate, 1 - 0.0095 / 0.059))
        #expect(approx(test.falseOmissionRate, 1 - 0.9405 / 0.941))
    }

    @Test func probabilitiesSumToOne() throws {
        let test = try #require(DiagnosticTest(prevalencePercent: 37.5, sensitivityPercent: 81.2, specificityPercent: 66.6))
        #expect(approx(test.probabilityPositive + test.probabilityNegative, 1))
    }

    @Test(arguments: [
        (-1.0, 50.0, 50.0), (101.0, 50.0, 50.0),
        (50.0, -0.1, 50.0), (50.0, 100.1, 50.0),
        (50.0, 50.0, -5.0), (50.0, 50.0, 250.0),
        (Double.nan, 50.0, 50.0), (Double.infinity, 50.0, 50.0),
    ])
    func rejectsOutOfRangeInput(prevalence: Double, sensitivity: Double, specificity: Double) {
        #expect(DiagnosticTest(prevalencePercent: prevalence, sensitivityPercent: sensitivity, specificityPercent: specificity) == nil)
    }

    @Test func boundaryValuesAreAccepted() {
        #expect(DiagnosticTest(prevalencePercent: 0, sensitivityPercent: 0, specificityPercent: 0) != nil)
        #expect(DiagnosticTest(prevalencePercent: 100, sensitivityPercent: 100, specificityPercent: 100) != nil)
    }

    @Test func undefinedRatiosAreNilInsteadOfNaN() throws {
        // Nobody sick and a perfectly specific test → nobody tests positive.
        let noPositives = try #require(DiagnosticTest(prevalencePercent: 0, sensitivityPercent: 90, specificityPercent: 100))
        #expect(noPositives.probabilityPositive == 0)
        #expect(noPositives.positivePredictiveValue == nil)
        #expect(noPositives.falseDiscoveryRate == nil)
        #expect(approx(noPositives.negativePredictiveValue, 1))

        // Everyone sick and a perfectly sensitive test → nobody tests negative.
        let noNegatives = try #require(DiagnosticTest(prevalencePercent: 100, sensitivityPercent: 100, specificityPercent: 50))
        #expect(noNegatives.negativePredictiveValue == nil)
        #expect(noNegatives.falseOmissionRate == nil)
        #expect(approx(noNegatives.positivePredictiveValue, 1))
    }

    @Test func populationBreakdownMatchesClassicExample() throws {
        let test = try #require(DiagnosticTest(prevalencePercent: 1, sensitivityPercent: 95, specificityPercent: 95))
        let p = test.population()
        #expect(p.total == 100_000)
        #expect(p.sick == 1_000)
        #expect(p.healthy == 99_000)
        #expect(p.truePositives == 950)
        #expect(p.falseNegatives == 50)
        #expect(p.trueNegatives == 94_050)
        #expect(p.falsePositives == 4_950)
        #expect(p.testedPositive == 5_900)
        #expect(p.testedNegative == 94_100)
    }

    @Test(arguments: [
        (0.07, 99.9, 33.3), (12.345, 87.65, 92.1), (33.33, 66.67, 50.5), (0, 0, 0), (100, 100, 100),
    ])
    func populationCountsAlwaysAddUp(prevalence: Double, sensitivity: Double, specificity: Double) throws {
        let test = try #require(DiagnosticTest(prevalencePercent: prevalence, sensitivityPercent: sensitivity, specificityPercent: specificity))
        let p = test.population()
        #expect(p.sick + p.healthy == p.total)
        #expect(p.truePositives + p.falseNegatives == p.sick)
        #expect(p.trueNegatives + p.falsePositives == p.healthy)
        #expect(p.testedPositive + p.testedNegative == p.total)
        #expect([p.truePositives, p.falseNegatives, p.trueNegatives, p.falsePositives].allSatisfy { $0 >= 0 })
    }
}

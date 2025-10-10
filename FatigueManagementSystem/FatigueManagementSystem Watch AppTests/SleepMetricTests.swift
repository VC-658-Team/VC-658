//
//  SleepMetricTest.swift
//  FatigueManagementSystem Watch AppTests
//
//  Created by Apple on 6/10/2025.
//

import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct SleepMetricTests {
    let sleepMetric: SleepMetric!
    
    init() async throws {
        let healthstore = HKHealthStore()
        
        sleepMetric = SleepMetric(weight: 4, healthStore: healthstore)
        
    }
    @Test func testSleepMetricInitialisation() async throws {
        #expect(sleepMetric.name == "sleep")
        #expect(sleepMetric.weight == 4)
        #expect(sleepMetric.baseline == 0.65)
        #expect(sleepMetric.rawValue == 0.0)
    }
    
    @Test func testSleepMetricNormalisation() async throws {
        sleepMetric.rawValue = 0.4
        sleepMetric.baseline = 0.8
        
        let normalised = sleepMetric.normalisedValue()
        
        // Sleep normalization returns 1 - rawValue
        #expect(normalised == 0.6)
    }
    
    @Test func testSleepWeightedScore() async throws {
        sleepMetric.rawValue = 0.4
        sleepMetric.baseline = 0.8
        
        let weightedScore = sleepMetric.weightedScore()
        // Sleep normalization returns 1 - rawValue = 1 - 0.4 = 0.6
        let expectedScore = 0.6 * 4
        #expect(weightedScore == expectedScore)
        
    }

}

import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct StepsMetricTests {
    
    @Test func testStepsMetricInitialization() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        #expect(stepsMetric.name == "steps")
        #expect(stepsMetric.weight == 2.0)
        #expect(stepsMetric.rawValue == 0.0)
    }
    
    @Test func testStepsMetricNormalization() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        
        // At baseline = no extra fatigue
        stepsMetric.rawValue = 10000.0
        let normalValue = stepsMetric.normalisedValue()
        #expect(normalValue == 0.0)
        
        // Below baseline = less fatigue
        stepsMetric.rawValue = 5000.0
        let lessFatigueValue = stepsMetric.normalisedValue()
        #expect(lessFatigueValue == 0.0) // Capped at 0 (negative deviation)
        
        // Above baseline = more fatigue (50% more steps)
        stepsMetric.rawValue = 15000.0
        let moreFatigueValue = stepsMetric.normalisedValue()
        #expect(moreFatigueValue == 0.5)
        
        // Double baseline = maximum relative fatigue
        stepsMetric.rawValue = 20000.0
        let highFatigueValue = stepsMetric.normalisedValue()
        #expect(highFatigueValue == 1.0)
    }
    
    @Test func testStepsMetricWeightedScore() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        stepsMetric.rawValue = 15000.0 // 50% above baseline
        
        let weightedScore = stepsMetric.weightedScore()
        let expectedScore = 0.5 * 2.0 // normalizedValue * weight
        #expect(weightedScore == expectedScore)
    }
    
    @Test func testStepsStringFormatting() async throws {
        let fatigueModel = FatigueModel()
        
        let stepsString = fatigueModel.getStepsString()
        #expect(stepsString.contains("steps") || stepsString.contains("0 steps"))
    }
}


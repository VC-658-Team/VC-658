import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct CaloriesMetricTests {
    
    @Test func testCaloriesMetricInitialization() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        #expect(caloriesMetric.name == "calories")
        #expect(caloriesMetric.weight == 1.5)
        #expect(caloriesMetric.rawValue == 0.0)
    }
    
    @Test func testCaloriesMetricNormalization() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        caloriesMetric.baseline = 500.0
        
        // At baseline = no extra fatigue
        caloriesMetric.rawValue = 500.0
        let normalValue = caloriesMetric.normalisedValue()
        #expect(normalValue == 0.0)
        
        // Below baseline = less fatigue
        caloriesMetric.rawValue = 250.0
        let lessFatigueValue = caloriesMetric.normalisedValue()
        #expect(lessFatigueValue == 0.0) // Capped at 0 (negative deviation)
        
        // Above baseline = more fatigue (50% more calories)
        caloriesMetric.rawValue = 750.0
        let moreFatigueValue = caloriesMetric.normalisedValue()
        #expect(moreFatigueValue == 0.5)
        
        // Double baseline = maximum relative fatigue
        caloriesMetric.rawValue = 1000.0
        let highFatigueValue = caloriesMetric.normalisedValue()
        #expect(highFatigueValue == 1.0)
    }
    
    @Test func testCaloriesMetricWeightedScore() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        caloriesMetric.baseline = 500.0
        caloriesMetric.rawValue = 750.0 // 50% above baseline
        
        let weightedScore = caloriesMetric.weightedScore()
        let expectedScore = 0.5 * 1.5 // normalizedValue * weight
        #expect(weightedScore == expectedScore)
    }
    
    @Test func testCaloriesStringFormatting() async throws {
        let fatigueModel = FatigueModel()
        
        let caloriesString = fatigueModel.getCaloriesString()
        #expect(caloriesString.contains("cal") || caloriesString.contains("0 cal"))
    }
}


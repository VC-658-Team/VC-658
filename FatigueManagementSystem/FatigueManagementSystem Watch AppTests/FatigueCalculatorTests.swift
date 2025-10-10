import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct FatigueCalculatorTests {
    
    @Test func testFatigueCalculatorWithStepsAndCalories() async throws {
        let healthStore = HKHealthStore()
        let calculator = DefaultFatigueCalculator()
        
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        stepsMetric.rawValue = 15000.0 // 50% above baseline
        
        caloriesMetric.baseline = 500.0
        caloriesMetric.rawValue = 750.0 // 50% above baseline
        
        calculator.addMetric(key: "steps", value: stepsMetric)
        calculator.addMetric(key: "calories", value: caloriesMetric)
        
        // Use async continuation to wait for calculation
        let fatigueScore = await withCheckedContinuation { continuation in
            calculator.CalculateScore {
                continuation.resume(returning: calculator.fatigueScore)
            }
        }
        
        let expectedWeightedTotal = (0.5 * 2.0) + (0.5 * 1.5)
        let expectedTotalWeight = 2.0 + 1.5
        let expectedScore = Int((expectedWeightedTotal / expectedTotalWeight) * 100)
        
        #expect(fatigueScore == expectedScore)
    }
    
    @Test func testFatigueModelInitialization() async throws {
        let fatigueModel = FatigueModel()
        
        // Test that strings are initialized with default values
        #expect(fatigueModel.getStepsString().contains("steps"))
        #expect(fatigueModel.getCaloriesString().contains("cal"))
        #expect(fatigueModel.fatigueScore == 0)
    }
}


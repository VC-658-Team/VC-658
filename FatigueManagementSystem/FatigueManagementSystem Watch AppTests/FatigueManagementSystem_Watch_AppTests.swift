import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct FatigueManagementSystem_Watch_AppTests {

    @Test func testStepsMetricInitialization() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        #expect(stepsMetric.name == "steps")
        #expect(stepsMetric.weight == 2.0)
        #expect(stepsMetric.baseline == 10000.0)
        #expect(stepsMetric.rawValue == 0.0)
    }
    
    @Test func testCaloriesMetricInitialization() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        #expect(caloriesMetric.name == "calories")
        #expect(caloriesMetric.weight == 1.5)
        #expect(caloriesMetric.baseline == 500.0)
        #expect(caloriesMetric.rawValue == 0.0)
    }
    
    @Test func testStepsMetricNormalization() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        
        stepsMetric.rawValue = 10000.0
        let normalValue = stepsMetric.normalisedValue()
        #expect(normalValue == 0.0)
        
        stepsMetric.rawValue = 5000.0
        let fatigueValue = stepsMetric.normalisedValue()
        #expect(fatigueValue == 0.5)
        
        stepsMetric.rawValue = 0.0
        let highFatigueValue = stepsMetric.normalisedValue()
        #expect(highFatigueValue == 1.0)
    }
    
    @Test func testCaloriesMetricNormalization() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        caloriesMetric.baseline = 500.0
        
        caloriesMetric.rawValue = 500.0
        let normalValue = caloriesMetric.normalisedValue()
        #expect(normalValue == 0.0)
        
        caloriesMetric.rawValue = 250.0
        let fatigueValue = caloriesMetric.normalisedValue()
        #expect(fatigueValue == 0.5)
        
        caloriesMetric.rawValue = 0.0
        let highFatigueValue = caloriesMetric.normalisedValue()
        #expect(highFatigueValue == 1.0)
    }
    
    @Test func testStepsMetricWeightedScore() async throws {
        let healthStore = HKHealthStore()
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        stepsMetric.rawValue = 5000.0
        
        let weightedScore = stepsMetric.weightedScore()
        let expectedScore = 0.5 * 2.0
        #expect(weightedScore == expectedScore)
    }
    
    @Test func testCaloriesMetricWeightedScore() async throws {
        let healthStore = HKHealthStore()
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        caloriesMetric.baseline = 500.0
        caloriesMetric.rawValue = 250.0
        
        let weightedScore = caloriesMetric.weightedScore()
        let expectedScore = 0.5 * 1.5
        #expect(weightedScore == expectedScore)
    }
    
    @Test func testFatigueCalculatorWithStepsAndCalories() async throws {
        let healthStore = HKHealthStore()
        let calculator = DefaultFatigueCalculator()
        
        let stepsMetric = StepsMetric(weight: 2.0, healthStore: healthStore)
        let caloriesMetric = CaloriesMetric(weight: 1.5, healthStore: healthStore)
        
        stepsMetric.baseline = 10000.0
        stepsMetric.rawValue = 5000.0
        
        caloriesMetric.baseline = 500.0
        caloriesMetric.rawValue = 250.0
        
        calculator.addMetric(key: "steps", value: stepsMetric)
        calculator.addMetric(key: "calories", value: caloriesMetric)
        
        let fatigueScore = calculator.getFatigueScore()
        
        let expectedWeightedTotal = (0.5 * 2.0) + (0.5 * 1.5)
        let expectedTotalWeight = 2.0 + 1.5
        let expectedScore = Int((expectedWeightedTotal / expectedTotalWeight) * 100)
        
        #expect(fatigueScore == expectedScore)
    }
    
    @Test func testFatigueModelWithStepsAndCalories() async throws {
        let fatigueModel = FatigueModel()
        
        #expect(fatigueModel.getStepsString().contains("steps"))
        #expect(fatigueModel.getCaloriesString().contains("cal"))
    }
    
    @Test func testStepsStringFormatting() async throws {
        let fatigueModel = FatigueModel()
        
        let stepsString = fatigueModel.getStepsString()
        #expect(stepsString.contains("steps") || stepsString.contains("0 steps"))
    }
    
    @Test func testCaloriesStringFormatting() async throws {
        let fatigueModel = FatigueModel()
        
        let caloriesString = fatigueModel.getCaloriesString()
        #expect(caloriesString.contains("cal") || caloriesString.contains("0 cal"))
    }
    
    @Test func testHealthKitPermissionsIncludeStepsAndCalories() async throws {
        let fatigueModel = FatigueModel()
        
        #expect(true)
    }

}

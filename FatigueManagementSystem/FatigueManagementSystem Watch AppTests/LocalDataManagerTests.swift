import Testing
import HealthKit
@testable import FatigueManagementSystem_Watch_App

struct LocalDataManagerTests {
    
    @Test func testLocalDataManagerBaselineStorage() async throws {
        let localDataManager = LocalDataManager.shared
        
        localDataManager.saveBaseline(for: "steps", value: 8500.0)
        localDataManager.saveBaseline(for: "calories", value: 450.0)
        
        let stepsBaseline = localDataManager.getBaseline(for: "steps")
        let caloriesBaseline = localDataManager.getBaseline(for: "calories")
        
        #expect(stepsBaseline == 8500.0)
        #expect(caloriesBaseline == 450.0)
    }
    
    @Test func testLocalDataManagerDailyUpdateCheck() async throws {
        let localDataManager = LocalDataManager.shared
        
        localDataManager.saveBaseline(for: "steps", value: 10000.0)
        
        let shouldUpdate = localDataManager.shouldUpdateBaseline(for: "steps")
        #expect(shouldUpdate == false)
    }
    
    @Test func testLocalDataManagerFatigueScoreStorage() async throws {
        let localDataManager = LocalDataManager.shared
        
        localDataManager.saveDailyFatigueScore(75)
        
        let scores = localDataManager.getDailyFatigueScores()
        let today = Calendar.current.startOfDay(for: Date())
        
        #expect(scores[today] == 75)
    }
}


import Foundation

class LocalDataManager {
    static let shared = LocalDataManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private enum Keys {
        static let stepsBaseline = "steps_baseline"
        static let caloriesBaseline = "calories_baseline"
        static let sleepBaseline = "sleep_baseline"
        static let restingHRBaseline = "restingHR_baseline"
        static let stepsBaselineDate = "steps_baseline_date"
        static let caloriesBaselineDate = "calories_baseline_date"
        static let sleepBaselineDate = "sleep_baseline_date"
        static let restingHRBaselineDate = "restingHR_baseline_date"
        static let dailyFatigueScores = "daily_fatigue_scores"
        static let lastFatigueScoreDate = "last_fatigue_score_date"
    }
    
    func saveBaseline(for metric: String, value: Double) {
        let dateKey: String
        let baselineKey: String
        
        switch metric {
        case "steps":
            baselineKey = Keys.stepsBaseline
            dateKey = Keys.stepsBaselineDate
        case "calories":
            baselineKey = Keys.caloriesBaseline
            dateKey = Keys.caloriesBaselineDate
        case "sleep":
            baselineKey = Keys.sleepBaseline
            dateKey = Keys.sleepBaselineDate
        case "restingHR":
            baselineKey = Keys.restingHRBaseline
            dateKey = Keys.restingHRBaselineDate
        default:
            return
        }
        
        userDefaults.set(value, forKey: baselineKey)
        userDefaults.set(Date(), forKey: dateKey)
    }
    
    func getBaseline(for metric: String) -> Double? {
        let baselineKey: String
        
        switch metric {
        case "steps":
            baselineKey = Keys.stepsBaseline
        case "calories":
            baselineKey = Keys.caloriesBaseline
        case "sleep":
            baselineKey = Keys.sleepBaseline
        case "restingHR":
            baselineKey = Keys.restingHRBaseline
        default:
            return nil
        }
        
        return userDefaults.double(forKey: baselineKey) > 0 ? userDefaults.double(forKey: baselineKey) : nil
    }
    
    func shouldUpdateBaseline(for metric: String) -> Bool {
        let dateKey: String
        
        switch metric {
        case "steps":
            dateKey = Keys.stepsBaselineDate
        case "calories":
            dateKey = Keys.caloriesBaselineDate
        case "sleep":
            dateKey = Keys.sleepBaselineDate
        case "restingHR":
            dateKey = Keys.restingHRBaselineDate
        default:
            return true
        }
        
        guard let lastUpdate = userDefaults.object(forKey: dateKey) as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        return !calendar.isDate(lastUpdate, inSameDayAs: Date())
    }
    
    func saveDailyFatigueScore(_ score: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        
        var fatigueScores = getDailyFatigueScores()
        fatigueScores[today] = score
        
        let encodedData = try? JSONEncoder().encode(fatigueScores)
        userDefaults.set(encodedData, forKey: Keys.dailyFatigueScores)
        userDefaults.set(Date(), forKey: Keys.lastFatigueScoreDate)
    }
    
    func getDailyFatigueScores() -> [Date: Int] {
        guard let data = userDefaults.data(forKey: Keys.dailyFatigueScores),
              let scores = try? JSONDecoder().decode([Date: Int].self, from: data) else {
            return [:]
        }
        return scores
    }
    
    func getWeeklyAverageFatigue() -> Double {
        let scores = getDailyFatigueScores()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let recentScores = scores.filter { $0.key >= sevenDaysAgo }.values
        return recentScores.isEmpty ? 0.0 : Double(recentScores.reduce(0, +)) / Double(recentScores.count)
    }
    
    func getMonthlyAverageFatigue() -> Double {
        let scores = getDailyFatigueScores()
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let recentScores = scores.filter { $0.key >= thirtyDaysAgo }.values
        return recentScores.isEmpty ? 0.0 : Double(recentScores.reduce(0, +)) / Double(recentScores.count)
    }
    
    func getFatigueTrend() -> [Int] {
        let scores = getDailyFatigueScores()
        let calendar = Calendar.current
        
        var trend: [Int] = []
        for day in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            trend.append(scores[day] ?? 0)
        }
        
        return trend.reversed()
    }
    
    func clearOldData() {
        let scores = getDailyFatigueScores()
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let recentScores = scores.filter { $0.key >= thirtyDaysAgo }
        let encodedData = try? JSONEncoder().encode(recentScores)
        userDefaults.set(encodedData, forKey: Keys.dailyFatigueScores)
    }
}

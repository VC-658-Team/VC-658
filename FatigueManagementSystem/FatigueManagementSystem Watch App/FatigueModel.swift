import HealthKit
import UserNotifications

class FatigueModel: ObservableObject {
    private let healthstore = HKHealthStore()
    private var calculator = DefaultFatigueCalculator()
    private let localDataManager = LocalDataManager.shared
    @Published var authorised = false
    @Published var fatigueScore = 0
    
    init() {
        requestHealthkitAuthorization()
    }
    
    func getSleepString() -> String {
        guard let sleepMetric = calculator.Metrics["sleep"] else {
            return ""
        }
        let hours = Int(sleepMetric.rawValue)
        let remainingSeconds = hours % 3600
        let minutes = remainingSeconds / 60
        return "\(hours)hrs \(minutes)mins"
    }
    
    func getStepsString() -> String {
        guard let stepsMetric = calculator.Metrics["steps"] else {
            return "0 steps"
        }
        let steps = Int(stepsMetric.rawValue)
        if steps >= 1000 {
            return String(format: "%.1fK steps", Double(steps) / 1000)
        } else {
            return "\(steps) steps"
        }
    }
    
    func getCaloriesString() -> String {
        guard let caloriesMetric = calculator.Metrics["calories"] else {
            return "0 cal"
        }
        let calories = Int(caloriesMetric.rawValue)
        return "\(calories) cal"
    }
    
    func getFatigueScore() -> Int {
        fatigueScore = calculator.getFatigueScore()
        
        if fatigueScore > 80 {
            triggerNotification()
        }
        
        localDataManager.saveDailyFatigueScore(fatigueScore)
        localDataManager.clearOldData()
        
        return fatigueScore
    }
    
    func getWeeklyAverageFatigue() -> Double {
        return localDataManager.getWeeklyAverageFatigue()
    }
    
    func getMonthlyAverageFatigue() -> Double {
        return localDataManager.getMonthlyAverageFatigue()
    }
    
    func getFatigueTrend() -> [Int] {
        return localDataManager.getFatigueTrend()
    }
    
    func requestHealthkitAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Unauthorised notification error \(error.localizedDescription)")
            }
        }
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthstore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Healthkit authorization error: \(error.localizedDescription)")
            }
            else {
                DispatchQueue.main.async {
                    self.calculator.addMetric(key: "Resting Heart Rate", value: RestingHeartRateMetric(weight: 3.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "sleep",
                                              value: SleepDurationMetric(weight: 4.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "steps",
                                              value: StepsMetric(weight: 2.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "calories",
                                              value: CaloriesMetric(weight: 1.5, healthStore: self.healthstore))
                    self.authorised = true
                }
            }
        }
    }
    
    func triggerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Fatigue Warning"
        content.body = "Your are predicted to be fatigued"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
        print("made it")
    }
}
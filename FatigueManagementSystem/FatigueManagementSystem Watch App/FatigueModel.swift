//
//  FatigueModel.swift
//  FatigueManagementSystem
//
//  Created by Apple on 22/9/2025.
//


import HealthKit
import UserNotifications


class FatigueModel: ObservableObject {
    private let healthstore = HKHealthStore()
    private var calculator = DefaultFatigueCalculator()
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
        let remaingSeconds = hours % 3600
        let minutes = remaingSeconds / 60
        return "\(hours)hrs \(minutes)mins"
    }
    
    // adding restingheartrate string function
    func getRestingHRString() -> String {
        if let rhr = calculator.Metrics["restingHR"]?.rawValue, rhr > 0 {
            return "\(Int(rhr)) bpm"
        } else {
            return "-- bpm"
        }
    }
    
    
    func getFatigueScore()-> Int {
        fatigueScore = calculator.getFatigueScore()
        if(fatigueScore > 80) {
            triggerNotification()
        }
        return fatigueScore
    }
    // Request authorisation
    // Will need to be updated as more metrics are added
    func requestHealthkitAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Unauthorised notification error \(error.localizedDescription)")
            }
        }
        
        
        // Healthkit authorisation
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthstore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Healthkit authorization errorL \(error.localizedDescription)")
            }
            else {
                
                
                // works 
                DispatchQueue.main.async {
                    self.calculator.addMetric(key: "sleep",
                                              value: SleepDurationMetric(weight: 4.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "restingHR",
                                              value: RestingHeartRateMetric(weight: 3.0, healthStore: self.healthstore))
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



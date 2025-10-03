//
//  FatigueService.swift
//  FatigueManagementSystem
//
//  Created by Apple on 28/9/2025.
//

import HealthKit
import UserNotifications


class FatigueService {
    static let service = FatigueService()
    private let healthstore = HKHealthStore()
    public var calculator = DefaultFatigueCalculator()
    private var notificationsAuthed: Bool = false;
    var authorised = false;
    
    private init() {
    }

    func start() {
        requestHKAuthorization { authorised in
            if authorised {
                self.StartObservers()
            }
            else {
                print("Authorisation not granted")
            }
        }
        requestNotificationAuthorization { authorised in
            if authorised {
                self.notificationsAuthed = true
            }
        }
    }
    
    // Request notification authorisation
    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { success, error in
            if let error = error {
                print("Notification authorisation error: \(error.localizedDescription)")
            }
            else {
                completion(success)
            }
        }
    }
    
    // Healthkit authorisation
    func requestHKAuthorization(completion: @escaping (Bool) -> Void) {
        guard
            let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        else {
            completion(false)
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            rhrType,
            sleepType,
            stepType,
            energyType
        ]
        
        healthstore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Healthkit authorization error: \(error.localizedDescription)")
            }
            else {
                
                DispatchQueue.main.async {
                    self.calculator.addMetric(key: "sleep",
                                              value: SleepDurationMetric(weight: 4.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "restingHR",
                                              value: RestingHeartRateMetric(weight: 3.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "steps",
                                              value: StepsMetric(weight: 2.0, healthStore: self.healthstore))
                    self.calculator.addMetric(key: "calories",
                                              value: CaloriesMetric(weight: 1.5, healthStore: self.healthstore))
                    completion(success)
                    
                }
            }
        }
    }
    
    func StartObservers() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }
        healthstore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
            if !success {
                print("Failed to enable background deliver: \(String(describing: error))")
            }
        }
        
        let query = HKObserverQuery(sampleType: type, predicate: nil) {_, completion, _ in
            self.calculator.CalculateScore {
                completion()
            }
        }
        
        healthstore.execute(query)

    }

    func CalculateScore() {
        calculator.CalculateScore { [weak self] in
            guard let self = self else { return }
            if(calculator.FatigueScore > 80 && notificationsAuthed) {
                triggerNotification()
            }
        }
    }
    
    func triggerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Fatigue Warning"
        content.body = "You are predicted to be fatigued"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
    
}

//
//  FatigueModel.swift
//  FatigueManagementSystem
//
//  Created by Apple on 22/9/2025.
//
import HealthKit
import UserNotifications
import Combine

class FatigueModel: ObservableObject {
    private let healthstore = HKHealthStore()
    private let localDataManager = LocalDataManager.shared
    @Published var authorised = false
    @Published var fatigueScore = 0
    
    // test
    @Published var sleepString = "Score: 0"
    @Published var restingHRString = "-- bpm"
    @Published var stepsString = "0 steps"
    @Published var caloryString = "0 cal"
    
    // MODIFIED: Changed from 'private' to 'public' to allow ContentView to access it.
    public let service: FatigueService
    
    init(service: FatigueService) {
        self.service = service

    }
    
    func setSleepString() {
        guard let sleepMetric = service.calculator.metrics["sleep"] else {
            sleepString = "Score: O"
            return
        }
    
        sleepString = "Score: \(Int(sleepMetric.rawValue * 100))"
    }
    
    func setRestingHRString() {
        if let rhr = service.calculator.metrics["restingHR"]?.rawValue, rhr > 0 {
            restingHRString = "\(Int(rhr)) bpm"
        } else {
            restingHRString = "-- bpm"
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
    
    func getFatigueScore()-> Int {
        fatigueScore = calculator.getFatigueScore()
        if(fatigueScore > 80) {
            triggerNotification()
        }
    }

    func setStepsString() {
        guard let stepsMetric = service.calculator.metrics["steps"] else {
            stepsString = "0 steps"
            return
        }
        let steps = Int(stepsMetric.rawValue)
        if steps >= 1000 {
            stepsString = String(format: "%.1fK steps", Double(steps) / 1000)
        } else {
            stepsString = "\(steps) steps"
        }
    }
    
    func setCaloriesString() {
        guard let caloriesMetric = service.calculator.metrics["calories"] else {
            caloryString = "0 cal"
            return
        }
        let calories = Int(caloriesMetric.rawValue)
        caloryString = "\(calories) cal"
    }
    
    func getStepsString() -> String {
        return stepsString
    }
    
    func getCaloriesString() -> String {
        return caloryString
    }
    
    func getFatigueScore() {
        service.calculator.calculateScore { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.fatigueScore = self.service.calculator.fatigueScore
        
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthstore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("Healthkit authorization errorL \(error.localizedDescription)")
            }
            else {
                
                self.setSleepString()
                self.setRestingHRString()
                self.setStepsString()
                self.setCaloriesString()
                
                self.localDataManager.saveDailyFatigueScore(self.fatigueScore)
                self.localDataManager.clearOldData()
                
                // works 
                DispatchQueue.main.async {
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
    
    func getWeeklyAverageFatigue() -> Double {
        return localDataManager.getWeeklyAverageFatigue()
    }
    
    func getMonthlyAverageFatigue() -> Double {
        return localDataManager.getMonthlyAverageFatigue()
    }
    
    func getFatigueTrend() -> [Int] {
        return localDataManager.getFatigueTrend()
    }
}

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
                
                self.setSleepString()
                self.setRestingHRString()
                self.setStepsString()
                self.setCaloriesString()
                
                self.localDataManager.saveDailyFatigueScore(self.fatigueScore)
                self.localDataManager.clearOldData()
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

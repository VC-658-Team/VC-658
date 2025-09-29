//
//  FatigueModel.swift
//  FatigueManagementSystem
//
//  Created by Apple on 22/9/2025.
//


import HealthKit
import UserNotifications


class FatigueModel: ObservableObject {
    @Published var authorised = false
    @Published var fatigueScore = 0
    
    let service = FatigueService.service
    init() {
            
    }
    
    func getSleepString() -> String {
        guard let sleepMetric = service.calculator.Metrics["sleep"] else {
            return ""
        }
        let hours = Int(sleepMetric.rawValue)
        let remaingSeconds = hours % 3600
        let minutes = remaingSeconds / 60
        return "\(hours)hrs \(minutes)mins"
    }
    
    // adding restingheartrate string function
    func getRestingHRString() -> String {
        if let rhr = service.calculator.Metrics["restingHR"]?.rawValue, rhr > 0 {
            return "\(Int(rhr)) bpm"
        } else {
            return "-- bpm"
        }
    }
    
    func getFatigueScore()-> Int {
        return service.calculator.FatigueScore
    }
    
    
}



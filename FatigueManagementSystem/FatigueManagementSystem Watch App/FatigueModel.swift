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
    
    @Published var sleepString = "Score: 0"
    @Published var restingHRString = "-- bpm"
    
    let service = FatigueService.service
    init() {
            
    }
    
    func SetSleepString() {
        guard let sleepMetric = service.calculator.Metrics["sleep"] else {
            sleepString = "Score: O"
            return
        }
    
        sleepString = "Score: \(Int(sleepMetric.rawValue * 100))"
    }
    
    // adding restingheartrate string function
    func SetRestingHRString() {
        if let rhr = service.calculator.Metrics["restingHR"]?.rawValue, rhr > 0 {
            restingHRString = "\(Int(rhr)) bpm"
        } else {
            restingHRString = "-- bpm"
        }
    }
    
    func getFatigueScore() {
        SetSleepString()
        SetRestingHRString()
        service.CalculateScore()
        fatigueScore = service.calculator.FatigueScore
    }
    
    
}



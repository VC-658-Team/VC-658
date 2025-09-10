//
//  FatigueCalculator.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 10/9/2025.
//

import Foundation

protocol FatigueCalculator {
    
    var Metrics: Dictionary<String, FatigueMetric> { get }
    
    func addMetric(key: String, value: FatigueMetric)-> Void
    
    func GetFatigueScore() -> Int
    
    func getRawMetric(key: String) -> Double?
    
}

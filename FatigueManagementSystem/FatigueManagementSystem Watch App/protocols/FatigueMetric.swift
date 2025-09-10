//
//  FatigueMetric.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 10/9/2025.
//

import Foundation

protocol FatigueMetric {
    
    var weight: Double { get }
    var rawValue: Double { get }
    var minValue: Double { get }
    var maxValue: Double { get }
    
    func normalisedValue() -> Double
    

    func score() -> Int
    
    
}

extension FatigueMetric {
    var normalisedValue: Double {
        max(0, min(1 (rawValue - minValue) / (maxValue)))
    }
}

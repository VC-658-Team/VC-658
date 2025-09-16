//
//  RestingHeartRateMetric.swift
//  FatigueManagementSystem
//
//  Created by Sukhman Kaur Kang  on 16/9/2025.
//

import Foundation
import HealthKit
    
class RestingHeartRateMetric: FatigueMetric {
    let name = "restingheartrate"
    let weight: Double
    var baseline: Double
    var rawValue: Double
    
    let healthStore: HKHealthStore
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight;
        self.baseline = 60.0
        self.rawValue = 72.0
        self.healthStore - healthStore
        
        getRawValue()
        
        
    }
    
    func getRawValue() {
        getLatestRestingHearRate { bpm in self.rawValue = bpm
        }
    }
    
    private func getLatestRestingHeartRate(completion: @escaping (Double) -> Void) {
        guard let
    }
    
}
    


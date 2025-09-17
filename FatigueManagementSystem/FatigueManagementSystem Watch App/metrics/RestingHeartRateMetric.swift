//
//  RestingHeartRateMetric.swift
//  FatigueManagementSystem
//
//  Created by Sukhman Kaur Kang  on 16/9/2025.
//

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
    


//
//  RestingHeartRateMetric.swift
//  FatigueManagementSystem
//
//  Created by Sukhman Kaur Kang  on 16/9/2025.
//
import Foundation
import HealthKit


class RestingHeartRateMetric: FatigueMetric {
    
    
    let name = "Resting Heart Rate"
    let weight: Double
    var baseline: Double
    var rawValue: Double = 0.0 // this will be updated once we fetch data from the healthkit
    
    let healthStore: HKHealthStore
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight;
        self.baseline = 60.0
        self.healthStore = healthStore
        fetchLatest {bpm in
            if let bpm = bpm {
                DispatchQueue.main.async {
                    self.rawValue = bpm
                }
            }
        }
    }
    
    private func fetchLatest(completion: @escaping (Double?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil)
            return
        }
        
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type,
                                  predicate: nil, limit: 1,
                                  sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            completion(bpm)
        }
        healthStore.execute(query)
    }
    
    func calculateBaseline() {
        baseline = 60.0
    }
    
    func normalisedValue() -> Double {
        let minHR = 40.0
        let maxHR = 100.0
        let clamped = max(min(rawValue, maxHR), minHR)
        return (clamped - minHR) / (maxHR - minHR)
    }
}
        
        
        
      
        
        
        
        
        
    

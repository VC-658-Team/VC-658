//
//  RestingHeartRateMetric.swift
//  FatigueManagementSystem
//
//  Created by Sukhman Kaur Kang  on 16/9/2025.
//
import Foundation
import HealthKit

/*class RestingHeartRateMetric{
    private let healthStore = HKHealthStore()
    
    // GET AUTHORIZATION
    func requestAuthorization(completion: @escaping (Bool) -> Void){
        guard let restingHR = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else{
            completion(false)
            return
        }
        
        let readTypes: Set<HKObjectType> = [restingHR]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if  let error = error {
                print ("Healthkiit authorization error : \(error.localizedDescription)")
            }
            completion(success)
            
        }
    }
    
    //FETCH LATEST RESTING HEART RATE
    
    func fetchLatest(completion: @escaping (Double?) -> Void) {
        guard let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: restingHRType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]
        ) { _,results, _ in
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            completion(bpm)
        }
        
        healthStore.execute(query)
    }
    
    
    //NORMALISE
    
    func normalize(_value: Double) -> Double {
        let minHR = 40.0
        let maxHR = 100.0
        let clamped = max(min(_value, maxHR), minHR)
        return (clamped - minHR) / (maxHR - minHR)
    }
}
 */
// above is the code which is so far
//----------------------------------------------------------------------
//below is testing yet

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
        //getRawValue()
        
        //}
        
        //func getRawValue() {
        //bpm in self.rawValue = bpm
        //  }
        //func calculateBaseline() {
        //  baseline = 60.0
        
        //}
        
        //func normalisedValue() -> Double {
        
        //  let ratio = baseline / rawValue
        //return max(0, min(1, ratio))
        //}
        
        
        //}
        
        
        
        
        
    

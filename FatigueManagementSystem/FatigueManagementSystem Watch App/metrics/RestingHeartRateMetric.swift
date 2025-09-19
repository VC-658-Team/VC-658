//
//  RestingHeartRateMetric.swift
//  FatigueManagementSystem
//
//  Created by Sukhman Kaur Kang  on 16/9/2025.
//
import Foundation
import HealthKit

class RestingHeartRateMetric{
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
//class RestingHeartRateMetric: FatigueMetric {
  //  let name = "restingheartrate"
    //let weight: Double
    //var baseline: Double
    //var rawValue: Double
    
    //let healthStore: HKHealthStore
    
    //init(weight: Double, healthStore: HKHealthStore) {
      //  self.weight = weight;
        //self.baseline = 60.0
        //self.rawValue = 65.0
        //self.healthStore = healthStore
        
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

    

    


//
//  SleepMetric.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 12/9/2025.
//

import Foundation
import HealthKit

class SleepDurationMetric: FatigueMetric {
    
    let name = "sleep"
    let weight: Double
    var baseline: Double
    var rawValue: Double = 0.0
    
    let healthStore: HKHealthStore
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight;
        self.baseline = 8.0
        //self.rawValue = 0.0
        self.healthStore = healthStore
        
        fetchLastSleep { hours in
            DispatchQueue.main.async {
                self.rawValue = hours
            }
        }
    }
    
    private func fetchLastSleep(completion: @escaping (Double) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0); return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now.addingTimeInterval(-24 * 60 * 60))
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else {
                completion(0); return
            }
            
            let sleepSamples = samples.filter { $0.value != HKCategoryValueSleepAnalysis.awake.rawValue }
            
            let duration = sleepSamples.reduce(0) { (sum, sample) in
                sum + sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            let hours = duration / 3600.0
            completion(hours)
            
            
        }
        
        healthStore.execute(query)
    }
    //-------------------------------above testing
    /*func getRawValue() {
        self.rawValue = 1.0
        
        self.getLastSleepSample { seconds in
            self.rawValue = seconds / 3600
        }
    }
    
    func getLastSleepSample(completion: @escaping (TimeInterval) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startDay = calendar.date(byAdding: .day, value: -1, to: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil ) { (_, samples, error) in
            
            guard error == nil, let samples = samples as? [HKCategorySample] else {
                completion(0)
                return
            }
            
            let sleepSamples = samples.filter { sample in
                return sample.value != HKCategoryValueSleepAnalysis.awake.rawValue
            }
            let duration = sleepSamples.reduce(0) { (sum, sample) -> TimeInterval in
                return sum + sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            DispatchQueue.main.async {
                completion(duration)
            }
        }
        
        self.healthStore.execute(query)
    }
    */
    //-------------------------------below testing
    func calculateBaseline() {
        // get historical data
        //else choose average value
        baseline = 8.0
    }
    
    func normalisedValue() -> Double {
        let defecit = max(0, rawValue - baseline)
        return defecit / baseline
        //print(rawValue)
        //let val = (baseline - rawValue) / baseline
        //return max(0, min(1, val))
    }
    
}
    


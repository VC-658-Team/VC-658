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
        self.baseline = 0.65
        //self.rawValue = 0.0
        self.healthStore = healthStore
        
        fetchLastSleep { score in
            DispatchQueue.main.async {
                self.rawValue = score
            }
        }
    }
    
    private func fetchLastSleep(completion: @escaping (Double) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0); return
        }
        
        let now = Date()
        let startOfDay = Date(timeIntervalSinceNow: (-24 * 60 * 60))
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self]  _, samples, _ in
            guard let self, let samples = samples as? [HKCategorySample] else {
                completion(0); return
            }
        
            let sleepScore = self.calculateSleepScore(from: samples)
        
            completion(sleepScore)
        }
        healthStore.execute(query)
    }
    
    func calculateSleepScore(from samples: [HKCategorySample]) -> Double {
        // 1. Calculate total time for each stage
        var durationInBed: TimeInterval = 0
        var durationAsleep: TimeInterval = 0
        var durationREM: TimeInterval = 0
        var durationDeep: TimeInterval = 0
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .inBed:
                    durationInBed += duration
                case .asleepREM:
                    durationREM += duration
                    durationAsleep += duration
                case .asleepDeep:
                    durationDeep += duration
                    durationAsleep += duration
                case .asleepCore:
                    durationAsleep += duration
            case .asleepUnspecified:
                durationAsleep += duration
            default:
                continue
            }
        }
        
        // Prevent division by zero if there's no data
        if durationInBed == 0 { return 0 }
        
        // 2. Score each component (e.g., out of 100)
        // Score for total sleep duration (e.g., 8 hours is 100%)
        let totalSleepHours = durationAsleep / 3600
        let durationScore = min((totalSleepHours / 8.0) * 100, 100)

        // Score for sleep efficiency (e.g., 85% efficiency is 100%)
        let efficiency = (durationAsleep / durationInBed)
        let efficiencyScore = min((efficiency / 0.85) * 100, 100)
        
        // Score for deep sleep (e.g., 20% of total sleep is 100%)
        let deepPercentage = durationDeep / durationAsleep
        let deepScore = min((deepPercentage / 0.20) * 100, 100)

        // 3. Combine scores using weights
        let durationWeight = 0.40
        let efficiencyWeight = 0.30
        let deepSleepWeight = 0.30
        
        let finalScore = (durationScore * durationWeight) + (efficiencyScore * efficiencyWeight) + (deepScore * deepSleepWeight)
        
        return finalScore.rounded() / 100   
    }
    
//    func addUpTotal(for intervals: [DateInterval]) -> TimeInterval {
//        guard intervals.count > 1 else {
//            return intervals.first?.duration ?? 0
//        }
//        
//        let sorted = intervals.sorted { $0.start < $1.start }
//        
//        va
//    }
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
        baseline = 0.5
    }
    
    func normalisedValue() -> Double {
        return rawValue
        //print(rawValue)
        //let val = (baseline - rawValue) / baseline
        //return max(0, min(1, val))
    }
    
}
    


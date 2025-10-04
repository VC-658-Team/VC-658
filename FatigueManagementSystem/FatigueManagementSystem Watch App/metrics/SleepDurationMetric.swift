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
    var rawValue: Double
        
    let healthStore: HKHealthStore
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight;
        self.baseline = 0.65
        self.rawValue = 0.0
        self.healthStore = healthStore
        
        self.getRawValue {}
        
    }
    
    func getRawValue(completion: @escaping () -> Void) {
        self.rawValue = 1.0
        
        self.getLastSleepScore { [weak self] score in
            self?.rawValue = score
            completion()
        }
    }
    
    private func getLastSleepScore(completion: @escaping (Double) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0); return
        }
        
        let now = Date()
        let start = Date(timeIntervalSinceNow: (-24 * 60 * 60))
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate, limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor]) { [weak self]  _, samples, _ in
            guard let self, let samples = samples as? [HKCategorySample] else {
                completion(0)
                return
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
        guard durationInBed > 0 else { return 0 }
        guard durationAsleep > 0 else { return 0 }
        
        // Score each component (e.g., out of 100)
        // Score for total sleep duration (e.g., 8 hours is 100%)
        let totalSleepHours = durationAsleep / 3600
        let durationScore = min((totalSleepHours / 8.0) * 100, 100)

        // Score for sleep efficiency (e.g., 85% efficiency is 100%)
        let efficiency = (durationAsleep / durationInBed)
        let efficiencyScore = min((efficiency / 0.85) * 100, 100)
        
        // Score for deep sleep (e.g., 20% of total sleep is 100%)
        let deepPercentage = durationDeep / durationAsleep
        let deepScore = min((deepPercentage / 0.20) * 100, 100)

        // Combine scores using weights
        let durationWeight = 0.40
        let efficiencyWeight = 0.30
        let deepSleepWeight = 0.30
        
        let finalScore = (durationScore * durationWeight) + (efficiencyScore * efficiencyWeight) + (deepScore * deepSleepWeight)
        
        return finalScore.rounded() / 100   
    }

    //-------------------------------below testing
    func calculateBaseline() {
        // get historical data
        //else choose average value
        baseline = 0.5
    }
    
    func normalisedValue() -> Double {
        return rawValue
    }
    
}
    


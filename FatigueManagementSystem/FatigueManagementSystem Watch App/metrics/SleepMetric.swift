//
//  SleepMetric.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 12/9/2025.
//

import Foundation
import HealthKit

class SleepMetric: FatigueMetric {
    
    let name = "sleep"
    let weight: Double
    var baseline: Double
    var rawValue: Double
    
    let healthStore: HKHealthStore
    private let localDataManager = LocalDataManager.shared
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight;
        self.healthStore = healthStore
        
        self.baseline = localDataManager.getBaseline(for: "sleep") ?? 0.65
        self.rawValue = 0.0
        
        self.getRawValue {
            if self.localDataManager.shouldUpdateBaseline(for: "sleep") {
                self.calculateBaseline()
            }
        }
    }
    
    func getRawValue(completion: @escaping () -> Void) {
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
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        
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
        var durationAwake: TimeInterval = 0
        var durationAsleep: TimeInterval = 0
        var durationREM: TimeInterval = 0
        var durationDeep: TimeInterval = 0
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
            case .awake:
                    durationAwake += duration
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
        guard durationAwake > 0 else { return 0 }
        guard durationAsleep > 0 else { return 0 }

        let durationTotal = durationAsleep + durationAwake
        
        // Score each component (e.g., out of 100)
        // Score for total sleep duration (e.g., 8 hours is 100%)
        let totalSleepHours = durationAsleep / 3600
        let durationScore = min((totalSleepHours / 8.0) * 100, 100)
        
        // Score for sleep efficiency (e.g., 85% efficiency is 100%)
        let efficiency = (durationAsleep / durationTotal)
        let efficiencyScore = min((efficiency / 0.85) * 100, 100)
        
        // Score for deep sleep (e.g., 20% of total sleep is 100%)
        let deepPercentage = durationDeep / durationAsleep
        let deepScore = min((deepPercentage / 0.20) * 100, 100)
        
        // Combine scores using weights
        let durationWeight = 0.40
        let efficiencyWeight = 0.30
        let deepSleepWeight = 0.30
        
        let finalScore = (durationScore * durationWeight)
            + (efficiencyScore * efficiencyWeight)
            + (deepScore * deepSleepWeight)
        
        return finalScore.rounded() / 100
    }
    
    func getHistoricalSleepData(completion: @escaping ([Double]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }
        
        var dailySleepScores: [Double] = []
        let calendar = Calendar.current
        let endDate = Date()
        let numberOfDays = 30
        
        let group = DispatchGroup()
        
        for i in 1..<numberOfDays {
            guard let dayStart = calendar.date(byAdding: .day, value: -i, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
                guard let self = self, let samples = samples as? [HKCategorySample] else {
                    dailySleepScores.append(0.0)
                    group.leave()
                    return
                }
                
                let sleepScore = self.calculateSleepScore(from: samples)
                dailySleepScores.append(sleepScore)
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(dailySleepScores)
        }
    }

    func calculateBaseline() {
        self.getHistoricalSleepData { dailySleepScores in
            if !dailySleepScores.isEmpty {
                let totalScores = dailySleepScores.reduce(0, +)
                let newBaseline = totalScores / Double(dailySleepScores.count)
                
                self.baseline = newBaseline
                self.localDataManager.saveBaseline(for: "sleep", value: newBaseline)
            } else {
                let defaultBaseline = 0.65
                self.baseline = defaultBaseline
                self.localDataManager.saveBaseline(for: "sleep", value: defaultBaseline)
            }
        }
    }
    
    func normalisedValue() -> Double {
        return 1 - rawValue
    }
    
}

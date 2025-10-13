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
    var rawValue: Double = 0.0

    private let healthStore: HKHealthStore

    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight
        self.baseline = 60.0
        self.rawValue = 0.0
        self.healthStore = healthStore
    }
    
    func getRawValue(completion: @escaping () -> Void) {
        fetchLatest { [weak self] bpm in
            self?.rawValue = bpm ?? 0
            completion()
        }
    }
    
    private func fetchLatest(completion: @escaping (Double?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil); return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sort]
        ) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil); return
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
        let minHR = 40.0, maxHR = 100.0
        let clamped = max(min(rawValue, maxHR), minHR)
        return (clamped - minHR) / (maxHR - minHR)
    }
    
    // MARK: - Additional Data Methods for Charts
    
    /// Get historical resting heart rate data for the last 30 days
    func getHistoricalRestingHRData(completion: @escaping ([Double]) -> Void) {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion([])
            return
        }
        
        var dailyRHRValues: [Double] = []
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
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: rhrType,
                                      predicate: predicate,
                                      limit: 1,
                                      sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    dailyRHRValues.append(bpm)
                } else {
                    dailyRHRValues.append(0.0)
                }
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(dailyRHRValues)
        }
    }
    
    /// Get weekly averages for the last 7 days
    func getWeeklyAverages(completion: @escaping ([Double]) -> Void) {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion([])
            return
        }
        
        var weeklyAverages: [Double] = []
        let calendar = Calendar.current
        let group = DispatchGroup()
        
        for i in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -i, to: Date()),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: rhrType,
                                      predicate: predicate,
                                      limit: 1,
                                      sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    weeklyAverages.append(bpm)
                } else {
                    weeklyAverages.append(0.0)
                }
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(weeklyAverages.reversed()) // Most recent day first
        }
    }
    
    /// Get monthly averages for the last 7 months
    func getMonthlyAverages(completion: @escaping ([Double]) -> Void) {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion([])
            return
        }
        
        var monthlyAverages: [Double] = []
        let calendar = Calendar.current
        let group = DispatchGroup()
        
        for i in 0..<7 {
            guard let monthStart = calendar.date(byAdding: .month, value: -i, to: Date()),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(withStart: monthStart, end: monthEnd, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: rhrType,
                                      predicate: predicate,
                                      limit: 1,
                                      sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    monthlyAverages.append(bpm)
                } else {
                    monthlyAverages.append(0.0)
                }
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(monthlyAverages.reversed()) // Most recent month first
        }
    }

}

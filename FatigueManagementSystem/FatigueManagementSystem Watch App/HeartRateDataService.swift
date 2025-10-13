//
//  HeartRateDataService.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import Foundation
import HealthKit
import Combine

/// Service for fetching and managing heart rate data following latest Xcode documentation patterns
@MainActor
class HeartRateDataService: ObservableObject {
    @Published var currentHeartRate: Double = 0.0
    @Published var dailyHeartRateData: [HeartRateDataPoint] = []
    @Published var weeklyAverages: [Double] = []
    @Published var monthlyAverages: [Double] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let healthStore: HKHealthStore
    private let restingHRMetric: RestingHeartRateMetric
    
    init(healthStore: HKHealthStore, restingHRMetric: RestingHeartRateMetric) {
        self.healthStore = healthStore
        self.restingHRMetric = restingHRMetric
    }
    
    /// Fetch current heart rate
    func fetchCurrentHeartRate() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let currentHR = try await fetchLatestHeartRate()
            currentHeartRate = currentHR
        } catch {
            errorMessage = "Failed to fetch current heart rate: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Fetch daily heart rate data for the line graph
    func fetchDailyHeartRateData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dataPoints = try await fetchHourlyHeartRateData()
            dailyHeartRateData = dataPoints
        } catch {
            errorMessage = "Failed to fetch daily heart rate data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Fetch weekly average heart rate data
    func fetchWeeklyAverages() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let averages = try await fetchWeeklyHeartRateAverages()
            weeklyAverages = averages
        } catch {
            errorMessage = "Failed to fetch weekly averages: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Fetch monthly average heart rate data
    func fetchMonthlyAverages() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let averages = try await fetchMonthlyHeartRateAverages()
            monthlyAverages = averages
        } catch {
            errorMessage = "Failed to fetch monthly averages: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func fetchLatestHeartRate() async throws -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HeartRateError.healthKitUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: bpm)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchHourlyHeartRateData() async throws -> [HeartRateDataPoint] {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HeartRateError.healthKitUnavailable
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Group samples by hour and calculate average for each hour
                let hourlyData = self.processHourlyHeartRateData(samples: samples, startOfDay: startOfDay)
                continuation.resume(returning: hourlyData)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func processHourlyHeartRateData(samples: [HKQuantitySample], startOfDay: Date) -> [HeartRateDataPoint] {
        let calendar = Calendar.current
        var hourlyAverages: [Int: [Double]] = [:]
        
        for sample in samples {
            let hour = calendar.component(.hour, from: sample.startDate)
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            hourlyAverages[hour, default: []].append(bpm)
        }
        
        var dataPoints: [HeartRateDataPoint] = []
        for hour in 0..<24 {
            if let readings = hourlyAverages[hour], !readings.isEmpty {
                let average = readings.reduce(0, +) / Double(readings.count)
                let normalizedValue = normalizeHeartRate(average)
                dataPoints.append(HeartRateDataPoint(hour: hour, value: average, normalizedValue: normalizedValue))
            } else {
                // No data for this hour, use a default normalized value
                dataPoints.append(HeartRateDataPoint(hour: hour, value: 0, normalizedValue: 0.5))
            }
        }
        
        return dataPoints
    }
    
    private func fetchWeeklyHeartRateAverages() async throws -> [Double] {
        let calendar = Calendar.current
        var weeklyAverages: [Double] = []
        
        for i in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -i, to: Date()),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            let average = try await fetchDailyAverageHeartRate(startDate: dayStart, endDate: dayEnd)
            weeklyAverages.append(average)
        }
        
        return weeklyAverages.reversed() // Most recent day first
    }
    
    private func fetchMonthlyHeartRateAverages() async throws -> [Double] {
        let calendar = Calendar.current
        var monthlyAverages: [Double] = []
        
        // Get last 7 months of data
        for i in 0..<7 {
            guard let monthStart = calendar.date(byAdding: .month, value: -i, to: Date()),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                continue
            }
            
            let average = try await fetchMonthlyAverageHeartRate(startDate: monthStart, endDate: monthEnd)
            monthlyAverages.append(average)
        }
        
        return monthlyAverages.reversed() // Most recent month first
    }
    
    private func fetchDailyAverageHeartRate(startDate: Date, endDate: Date) async throws -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HeartRateError.healthKitUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let average = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0.0
                continuation.resume(returning: average)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchMonthlyAverageHeartRate(startDate: Date, endDate: Date) async throws -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HeartRateError.healthKitUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let average = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0.0
                continuation.resume(returning: average)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func normalizeHeartRate(_ bpm: Double) -> Double {
        let minHR = 40.0
        let maxHR = 120.0
        let clamped = max(min(bpm, maxHR), minHR)
        return (clamped - minHR) / (maxHR - minHR)
    }
}

// MARK: - Supporting Types

struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let hour: Int
    let value: Double
    let normalizedValue: Double
}

enum HeartRateError: LocalizedError {
    case healthKitUnavailable
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .healthKitUnavailable:
            return "HealthKit is not available"
        case .noDataAvailable:
            return "No heart rate data available"
        }
    }
}


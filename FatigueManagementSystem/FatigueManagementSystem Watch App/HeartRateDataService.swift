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
    
    /// Fetch current heart rate from existing RestingHeartRateMetric
    func fetchCurrentHeartRate() async {
        isLoading = true
        errorMessage = nil
        
        // Use the existing data from RestingHeartRateMetric
        currentHeartRate = restingHRMetric.rawValue
        print("DEBUG: Using existing heart rate data: \(currentHeartRate)")
        
        isLoading = false
    }
    
    /// Fetch daily heart rate data for the line graph
    func fetchDailyHeartRateData() async {
        isLoading = true
        errorMessage = nil
        
        // Use RestingHeartRateMetric to get historical data
        await withCheckedContinuation { continuation in
            restingHRMetric.getHistoricalRestingHRData { historicalData in
                // Convert historical data to chart data points
                let dataPoints = historicalData.enumerated().map { index, value in
                    HeartRateDataPoint(
                        hour: index,
                        value: value,
                        normalizedValue: self.normalizeHeartRate(value)
                    )
                }
                self.dailyHeartRateData = dataPoints
                print("DEBUG: Fetched \(dataPoints.count) daily heart rate data points from RestingHeartRateMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch weekly average heart rate data
    func fetchWeeklyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use RestingHeartRateMetric to get weekly data
        await withCheckedContinuation { continuation in
            restingHRMetric.getWeeklyAverages { averages in
                self.weeklyAverages = averages
                print("DEBUG: Fetched \(averages.count) weekly averages from RestingHeartRateMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch monthly average heart rate data
    func fetchMonthlyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use RestingHeartRateMetric to get monthly data
        await withCheckedContinuation { continuation in
            restingHRMetric.getMonthlyAverages { averages in
                self.monthlyAverages = averages
                print("DEBUG: Fetched \(averages.count) monthly averages from RestingHeartRateMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    
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


//
//  SleepDataService.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import Foundation
import HealthKit
import Combine

/// Service for fetching and managing sleep data following latest Xcode documentation patterns
@MainActor
class SleepDataService: ObservableObject {
    @Published var currentSleepScore: Double = 0.0
    @Published var dailySleepData: [SleepDataPoint] = []
    @Published var weeklyAverages: [Double] = []
    @Published var monthlyAverages: [Double] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let healthStore: HKHealthStore
    private let sleepMetric: SleepMetric
    
    init(healthStore: HKHealthStore, sleepMetric: SleepMetric) {
        self.healthStore = healthStore
        self.sleepMetric = sleepMetric
    }
    
    /// Fetch current sleep score from existing SleepMetric
    func fetchCurrentSleepScore() async {
        isLoading = true
        errorMessage = nil
        
        // Use the existing data from SleepMetric
        currentSleepScore = sleepMetric.rawValue
        print("DEBUG: Using existing sleep data: \(currentSleepScore)")
        
        isLoading = false
    }
    
    /// Fetch daily sleep data for the line graph
    func fetchDailySleepData() async {
        isLoading = true
        errorMessage = nil
        
        // Use SleepMetric to get historical data
        await withCheckedContinuation { continuation in
            sleepMetric.getHistoricalSleepData { historicalData in
                // Convert historical data to chart data points
                let dataPoints = historicalData.enumerated().map { index, value in
                    SleepDataPoint(
                        day: index,
                        value: value,
                        normalizedValue: self.normalizeSleepScore(value)
                    )
                }
                self.dailySleepData = dataPoints
                print("DEBUG: Fetched \(dataPoints.count) daily sleep data points from SleepMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch weekly average sleep data
    func fetchWeeklyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use SleepMetric to get weekly data
        await withCheckedContinuation { continuation in
            sleepMetric.getHistoricalSleepData { historicalData in
                // Get last 7 days of data
                let last7Days = Array(historicalData.prefix(7))
                self.weeklyAverages = last7Days
                print("DEBUG: Fetched \(last7Days.count) weekly averages from SleepMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch monthly average sleep data
    func fetchMonthlyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use SleepMetric to get monthly data
        await withCheckedContinuation { continuation in
            sleepMetric.getHistoricalSleepData { historicalData in
                // Get last 7 weeks of data (approximating months)
                let last7Weeks = Array(historicalData.prefix(7))
                self.monthlyAverages = last7Weeks
                print("DEBUG: Fetched \(last7Weeks.count) monthly averages from SleepMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func normalizeSleepScore(_ score: Double) -> Double {
        // Sleep scores are already normalized (0-1), but we can ensure they're in the right range
        return max(0.0, min(1.0, score))
    }
}

// MARK: - Supporting Types

struct SleepDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let value: Double
    let normalizedValue: Double
}

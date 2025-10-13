//
//  StepsDataService.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import Foundation
import HealthKit
import Combine

/// Service for fetching and managing steps data following latest Xcode documentation patterns
@MainActor
class StepsDataService: ObservableObject {
    @Published var currentSteps: Int = 0
    @Published var dailyStepsData: [StepsDataPoint] = []
    @Published var weeklyAverages: [Int] = []
    @Published var monthlyAverages: [Int] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let healthStore: HKHealthStore
    private let stepsMetric: StepsMetric
    
    init(healthStore: HKHealthStore, stepsMetric: StepsMetric) {
        self.healthStore = healthStore
        self.stepsMetric = stepsMetric
    }
    
    /// Fetch current steps from existing StepsMetric
    func fetchCurrentSteps() async {
        isLoading = true
        errorMessage = nil
        
        // Use the existing data from StepsMetric
        currentSteps = Int(stepsMetric.rawValue)
        print("DEBUG: Using existing steps data: \(currentSteps)")
        
        isLoading = false
    }
    
    /// Fetch daily steps data for the line graph
    func fetchDailyStepsData() async {
        isLoading = true
        errorMessage = nil
        
        // Use StepsMetric to get historical data
        await withCheckedContinuation { continuation in
            stepsMetric.getHistoricalStepsData { historicalData in
                // Convert historical data to chart data points
                let dataPoints = historicalData.enumerated().map { index, value in
                    StepsDataPoint(
                        day: index,
                        value: value,
                        normalizedValue: self.normalizeSteps(value)
                    )
                }
                self.dailyStepsData = dataPoints
                print("DEBUG: Fetched \(dataPoints.count) daily steps data points from StepsMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch weekly average steps data
    func fetchWeeklyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use StepsMetric to get weekly data
        await withCheckedContinuation { continuation in
            stepsMetric.getHistoricalStepsData { historicalData in
                // Get last 7 days of data
                let last7Days = Array(historicalData.prefix(7))
                self.weeklyAverages = last7Days
                print("DEBUG: Fetched \(last7Days.count) weekly averages from StepsMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch monthly average steps data
    func fetchMonthlyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use StepsMetric to get monthly data
        await withCheckedContinuation { continuation in
            stepsMetric.getHistoricalStepsData { historicalData in
                // Get last 7 weeks of data (approximating months)
                let last7Weeks = Array(historicalData.prefix(7))
                self.monthlyAverages = last7Weeks
                print("DEBUG: Fetched \(last7Weeks.count) monthly averages from StepsMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func normalizeSteps(_ steps: Int) -> Double {
        let minSteps = 0
        let maxSteps = 20000
        let clamped = max(min(steps, maxSteps), minSteps)
        return Double(clamped) / Double(maxSteps)
    }
}

// MARK: - Supporting Types

struct StepsDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let value: Int
    let normalizedValue: Double
}

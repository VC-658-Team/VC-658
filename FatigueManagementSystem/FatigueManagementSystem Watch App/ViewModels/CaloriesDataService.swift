//
//  CaloriesDataService.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import Foundation
import HealthKit
import Combine

/// Service for fetching and managing calories data following latest Xcode documentation patterns
@MainActor
class CaloriesDataService: ObservableObject {
    @Published var currentCalories: Double = 0.0
    @Published var dailyCaloriesData: [CaloriesDataPoint] = []
    @Published var weeklyAverages: [Double] = []
    @Published var monthlyAverages: [Double] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let healthStore: HKHealthStore
    private let caloriesMetric: CaloriesMetric
    
    init(healthStore: HKHealthStore, caloriesMetric: CaloriesMetric) {
        self.healthStore = healthStore
        self.caloriesMetric = caloriesMetric
    }
    
    /// Fetch current calories from existing CaloriesMetric
    func fetchCurrentCalories() async {
        isLoading = true
        errorMessage = nil
        
        // Use the existing data from CaloriesMetric
        currentCalories = caloriesMetric.rawValue
        print("DEBUG: Using existing calories data: \(currentCalories)")
        
        isLoading = false
    }
    
    /// Fetch daily calories data for the line graph
    func fetchDailyCaloriesData() async {
        isLoading = true
        errorMessage = nil
        
        // Use CaloriesMetric to get historical data
        await withCheckedContinuation { continuation in
            caloriesMetric.getHistoricalCaloriesData { historicalData in
                // Convert historical data to chart data points
                let dataPoints = historicalData.enumerated().map { index, value in
                    CaloriesDataPoint(
                        day: index,
                        value: value,
                        normalizedValue: self.normalizeCalories(value)
                    )
                }
                self.dailyCaloriesData = dataPoints
                print("DEBUG: Fetched \(dataPoints.count) daily calories data points from CaloriesMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch weekly average calories data
    func fetchWeeklyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use CaloriesMetric to get weekly data
        await withCheckedContinuation { continuation in
            caloriesMetric.getHistoricalCaloriesData { historicalData in
                // Get last 7 days of data
                let last7Days = Array(historicalData.prefix(7))
                self.weeklyAverages = last7Days
                print("DEBUG: Fetched \(last7Days.count) weekly averages from CaloriesMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    /// Fetch monthly average calories data
    func fetchMonthlyAverages() async {
        isLoading = true
        errorMessage = nil
        
        // Use CaloriesMetric to get monthly data
        await withCheckedContinuation { continuation in
            caloriesMetric.getHistoricalCaloriesData { historicalData in
                // Get last 7 weeks of data (approximating months)
                let last7Weeks = Array(historicalData.prefix(7))
                self.monthlyAverages = last7Weeks
                print("DEBUG: Fetched \(last7Weeks.count) monthly averages from CaloriesMetric")
                continuation.resume()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func normalizeCalories(_ calories: Double) -> Double {
        let minCalories = 0.0
        let maxCalories = 1000.0
        let clamped = max(min(calories, maxCalories), minCalories)
        return clamped / maxCalories
    }
}

// MARK: - Supporting Types

struct CaloriesDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let value: Double
    let normalizedValue: Double
}

//
//  CaloriesDetailView.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import SwiftUI
import HealthKit

struct CaloriesDetailView: View {
    @ObservedObject var fatigueModel: FatigueModel
    @StateObject private var caloriesService: CaloriesDataService
    
    init(fatigueModel: FatigueModel) {
        self.fatigueModel = fatigueModel
        // Initialize with the existing health store and calories metric from FatigueModel
        let healthStore = fatigueModel.service.healthstore
        let caloriesMetric = fatigueModel.service.calculator.metrics["calories"] as? CaloriesMetric ?? CaloriesMetric(weight: 1.5, healthStore: healthStore)
        _caloriesService = StateObject(wrappedValue: CaloriesDataService(healthStore: healthStore, caloriesMetric: caloriesMetric))
    }
    
    var body: some View {
        TabView {
            DailyCaloriesView(caloriesService: caloriesService)
            WeeklyAverageCaloriesView(caloriesService: caloriesService)
            MonthlyAverageCaloriesView(caloriesService: caloriesService)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .task {
            // Load all calories data when the view appears
            await caloriesService.fetchCurrentCalories()
            await caloriesService.fetchDailyCaloriesData()
            await caloriesService.fetchWeeklyAverages()
            await caloriesService.fetchMonthlyAverages()
        }
        .onAppear {
            // Use the current calories from FatigueModel if available
            if let caloriesMetric = fatigueModel.service.calculator.metrics["calories"] as? CaloriesMetric {
                caloriesService.currentCalories = caloriesMetric.rawValue
                print("DEBUG: Using existing calories data: \(caloriesMetric.rawValue)")
            } else {
                print("DEBUG: No existing calories data found")
            }
        }
    }
}

// MARK: - Daily Calories View
struct DailyCaloriesView: View {
    @ObservedObject var caloriesService: CaloriesDataService
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }
    
    private var graphData: [CGFloat] {
        caloriesService.dailyCaloriesData.map { CGFloat($0.normalizedValue) }
    }
    
    private var currentCalories: String {
        if caloriesService.isLoading {
            return "--"
        } else if caloriesService.currentCalories > 0 {
            return "\(Int(caloriesService.currentCalories))"
        } else {
            return "--"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (Current Calories)
            HStack {
                Text(currentCalories)
                    .font(.system(size: 40, weight: .semibold))
                    .baselineOffset(-4) +
                Text(" cal")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            .padding(.horizontal)

            // Line Graph
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.blue.opacity(0.6))
                
                if caloriesService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(0.8)
                } else if !graphData.isEmpty {
                    LineGraph(dataPoints: graphData)
                        .stroke(Color.orange, lineWidth: 2.5)
                } else {
                    Text("No data")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 70)
            .padding(.bottom, 4)

            // X-Axis Time Labels
            HStack {
                Text("0:00")
                Spacer()
                Text("24:00")
            }
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.horizontal)
            
            Spacer().frame(height: 10)

            // Date Information
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(dayFormatter.string(from: Date()))
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    Text(dateFormatter.string(from: Date()))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 6)
    }
}

// MARK: - Weekly Average Calories View
struct WeeklyAverageCaloriesView: View {
    @ObservedObject var caloriesService: CaloriesDataService
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var graphData: [CGFloat] {
        guard !caloriesService.weeklyAverages.isEmpty else { return [] }
        let maxValue = caloriesService.weeklyAverages.max() ?? 1000.0
        let minValue = caloriesService.weeklyAverages.min() ?? 0.0
        let range = maxValue - minValue
        
        return caloriesService.weeklyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var weeklyAverage: String {
        if caloriesService.isLoading {
            return "--"
        } else if !caloriesService.weeklyAverages.isEmpty {
            let average = caloriesService.weeklyAverages.reduce(0, +) / Double(caloriesService.weeklyAverages.count)
            return "\(Int(average))"
        } else {
            return "--"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(weeklyAverage)
                    .font(.system(size: 40, weight: .semibold))
                Text("avg weekly cal")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("\(Int(caloriesService.weeklyAverages.max() ?? 1000))")
                    Spacer()
                    Text("\(Int(caloriesService.weeklyAverages.min() ?? 0))")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if caloriesService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .orange)
                        Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6))
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(height: 60)
                    }
                    
                    HStack {
                        ForEach(dayLabels, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 6)
    }
}

// MARK: - Monthly Average Calories View
struct MonthlyAverageCaloriesView: View {
    @ObservedObject var caloriesService: CaloriesDataService
    
    private var monthLabels: [(id: String, label: String)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        var labels: [(id: String, label: String)] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let monthLabel = formatter.string(from: date)
                let uniqueId = "\(monthLabel)-\(i)"
                labels.append((id: uniqueId, label: monthLabel))
            }
        }
        return labels.reversed()
    }
    
    private var graphData: [CGFloat] {
        guard !caloriesService.monthlyAverages.isEmpty else { return [] }
        let maxValue = caloriesService.monthlyAverages.max() ?? 1000.0
        let minValue = caloriesService.monthlyAverages.min() ?? 0.0
        let range = maxValue - minValue
        
        return caloriesService.monthlyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var monthlyAverage: String {
        if caloriesService.isLoading {
            return "--"
        } else if !caloriesService.monthlyAverages.isEmpty {
            let average = caloriesService.monthlyAverages.reduce(0, +) / Double(caloriesService.monthlyAverages.count)
            return "\(Int(average))"
        } else {
            return "--"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(monthlyAverage)
                    .font(.system(size: 40, weight: .semibold))
                Text("avg monthly cal")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("\(Int(caloriesService.monthlyAverages.max() ?? 1000))")
                    Spacer()
                    Text("\(Int(caloriesService.monthlyAverages.min() ?? 0))")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if caloriesService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(0.8)
                        .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .orange)
                        Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6))
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(height: 60)
                    }
                    
                    HStack {
                        ForEach(monthLabels, id: \.id) { month in
                            Text(month.label)
                                .font(.system(size: 8))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 6)
    }
}

// MARK: - Preview
struct CaloriesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let healthStore = HKHealthStore()
            let service = FatigueService()
            let fatigueModel = FatigueModel(service: service)
            CaloriesDetailView(fatigueModel: fatigueModel)
        }
    }
}

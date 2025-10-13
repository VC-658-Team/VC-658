//
//  StepsDetailView.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import SwiftUI
import HealthKit

struct StepsDetailView: View {
    @ObservedObject var fatigueModel: FatigueModel
    @StateObject private var stepsService: StepsDataService
    
    init(fatigueModel: FatigueModel) {
        self.fatigueModel = fatigueModel
        // Initialize with the existing health store and steps metric from FatigueModel
        let healthStore = fatigueModel.service.healthstore
        let stepsMetric = fatigueModel.service.calculator.metrics["steps"] as? StepsMetric ?? StepsMetric(weight: 2.0, healthStore: healthStore)
        _stepsService = StateObject(wrappedValue: StepsDataService(healthStore: healthStore, stepsMetric: stepsMetric))
    }
    
    var body: some View {
        TabView {
            DailyStepsView(stepsService: stepsService)
            WeeklyAverageStepsView(stepsService: stepsService)
            MonthlyAverageStepsView(stepsService: stepsService)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .task {
            // Load all steps data when the view appears
            await stepsService.fetchCurrentSteps()
            await stepsService.fetchDailyStepsData()
            await stepsService.fetchWeeklyAverages()
            await stepsService.fetchMonthlyAverages()
        }
        .onAppear {
            // Use the current steps from FatigueModel if available
            if let stepsMetric = fatigueModel.service.calculator.metrics["steps"] as? StepsMetric {
                stepsService.currentSteps = Int(stepsMetric.rawValue)
                print("DEBUG: Using existing steps data: \(stepsMetric.rawValue)")
            } else {
                print("DEBUG: No existing steps data found")
            }
        }
    }
}

// MARK: - Daily Steps View
struct DailyStepsView: View {
    @ObservedObject var stepsService: StepsDataService
    
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
        stepsService.dailyStepsData.map { CGFloat($0.normalizedValue) }
    }
    
    private var currentSteps: String {
        if stepsService.isLoading {
            return "--"
        } else if stepsService.currentSteps > 0 {
            return "\(stepsService.currentSteps)"
        } else {
            return "--"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (Current Steps)
            HStack {
                Text(currentSteps)
                    .font(.system(size: 40, weight: .semibold))
                    .baselineOffset(-4) +
                Text(" steps")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
            }
            .padding(.horizontal)

            // Line Graph
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.blue.opacity(0.6))
                
                if stepsService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(0.8)
                } else if !graphData.isEmpty {
                    LineGraph(dataPoints: graphData)
                        .stroke(Color.green, lineWidth: 2.5)
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

// MARK: - Weekly Average Steps View
struct WeeklyAverageStepsView: View {
    @ObservedObject var stepsService: StepsDataService
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var graphData: [CGFloat] {
        guard !stepsService.weeklyAverages.isEmpty else { return [] }
        let maxValue = stepsService.weeklyAverages.max() ?? 10000
        let minValue = stepsService.weeklyAverages.min() ?? 0
        let range = maxValue - minValue
        
        return stepsService.weeklyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat(Double(value - minValue) / Double(range))
        }
    }
    
    private var weeklyAverage: String {
        if stepsService.isLoading {
            return "--"
        } else if !stepsService.weeklyAverages.isEmpty {
            let average = stepsService.weeklyAverages.reduce(0, +) / stepsService.weeklyAverages.count
            return "\(average)"
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
                Text("avg weekly steps")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("\(stepsService.weeklyAverages.max() ?? 10000)")
                    Spacer()
                    Text("\(stepsService.weeklyAverages.min() ?? 0)")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if stepsService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .green)
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

// MARK: - Monthly Average Steps View
struct MonthlyAverageStepsView: View {
    @ObservedObject var stepsService: StepsDataService
    
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
        guard !stepsService.monthlyAverages.isEmpty else { return [] }
        let maxValue = stepsService.monthlyAverages.max() ?? 10000
        let minValue = stepsService.monthlyAverages.min() ?? 0
        let range = maxValue - minValue
        
        return stepsService.monthlyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat(Double(value - minValue) / Double(range))
        }
    }
    
    private var monthlyAverage: String {
        if stepsService.isLoading {
            return "--"
        } else if !stepsService.monthlyAverages.isEmpty {
            let average = stepsService.monthlyAverages.reduce(0, +) / stepsService.monthlyAverages.count
            return "\(average)"
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
                Text("avg monthly steps")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("\(stepsService.monthlyAverages.max() ?? 10000)")
                    Spacer()
                    Text("\(stepsService.monthlyAverages.min() ?? 0)")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if stepsService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .green)
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
struct StepsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let healthStore = HKHealthStore()
            let service = FatigueService()
            let fatigueModel = FatigueModel(service: service)
            StepsDetailView(fatigueModel: fatigueModel)
        }
    }
}

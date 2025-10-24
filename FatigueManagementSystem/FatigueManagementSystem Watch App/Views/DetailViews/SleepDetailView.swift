//
//  SleepDetailView.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import SwiftUI
import HealthKit

struct SleepDetailView: View {
    @ObservedObject var fatigueModel: FatigueModel
    @StateObject private var sleepService: SleepDataService
    
    init(fatigueModel: FatigueModel) {
        self.fatigueModel = fatigueModel
        // Initialize with the existing health store and sleep metric from FatigueModel
        let healthStore = fatigueModel.service.healthstore
        let sleepMetric = fatigueModel.service.calculator.metrics["sleep"] as? SleepMetric ?? SleepMetric(weight: 4.0, healthStore: healthStore)
        _sleepService = StateObject(wrappedValue: SleepDataService(healthStore: healthStore, sleepMetric: sleepMetric))
    }
    
    var body: some View {
        TabView {
            DailySleepView(sleepService: sleepService)
            WeeklyAverageSleepView(sleepService: sleepService)
            MonthlyAverageSleepView(sleepService: sleepService)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .task {
            // Load all sleep data when the view appears
            await sleepService.fetchCurrentSleepScore()
            await sleepService.fetchDailySleepData()
            await sleepService.fetchWeeklyAverages()
            await sleepService.fetchMonthlyAverages()
        }
        .onAppear {
            // Use the current sleep score from FatigueModel if available
            if let sleepMetric = fatigueModel.service.calculator.metrics["sleep"] as? SleepMetric {
                sleepService.currentSleepScore = sleepMetric.rawValue
                print("DEBUG: Using existing sleep data: \(sleepMetric.rawValue)")
            } else {
                print("DEBUG: No existing sleep data found")
            }
        }
    }
}

// MARK: - Daily Sleep View
struct DailySleepView: View {
    @ObservedObject var sleepService: SleepDataService
    
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
        sleepService.dailySleepData.map { CGFloat($0.normalizedValue) }
    }
    
    private var currentSleepScore: String {
        if sleepService.isLoading {
            return "--"
        } else if sleepService.currentSleepScore > 0 {
            return "\(Int(sleepService.currentSleepScore * 100))"
        } else {
            return "--"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (Current Sleep Score)
            HStack {
                Text(currentSleepScore)
                    .font(.system(size: 40, weight: .semibold))
                    .baselineOffset(-4) +
                Text(" sleep score")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(.horizontal)

            // Line Graph
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.blue.opacity(0.6))
                
                if sleepService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(0.8)
                } else if !graphData.isEmpty {
                    LineGraph(dataPoints: graphData)
                        .stroke(Color.blue, lineWidth: 2.5)
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

// MARK: - Weekly Average Sleep View
struct WeeklyAverageSleepView: View {
    @ObservedObject var sleepService: SleepDataService
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var graphData: [CGFloat] {
        guard !sleepService.weeklyAverages.isEmpty else { return [] }
        let maxValue = sleepService.weeklyAverages.max() ?? 1.0
        let minValue = sleepService.weeklyAverages.min() ?? 0.0
        let range = maxValue - minValue
        
        return sleepService.weeklyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var weeklyAverage: String {
        if sleepService.isLoading {
            return "--"
        } else if !sleepService.weeklyAverages.isEmpty {
            let average = sleepService.weeklyAverages.reduce(0, +) / Double(sleepService.weeklyAverages.count)
            return "\(Int(average * 100))"
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
                Text("avg weekly score")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("100")
                    Spacer()
                    Text("0")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if sleepService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .blue)
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

// MARK: - Monthly Average Sleep View
struct MonthlyAverageSleepView: View {
    @ObservedObject var sleepService: SleepDataService
    
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
        guard !sleepService.monthlyAverages.isEmpty else { return [] }
        let maxValue = sleepService.monthlyAverages.max() ?? 1.0
        let minValue = sleepService.monthlyAverages.min() ?? 0.0
        let range = maxValue - minValue
        
        return sleepService.monthlyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var monthlyAverage: String {
        if sleepService.isLoading {
            return "--"
        } else if !sleepService.monthlyAverages.isEmpty {
            let average = sleepService.monthlyAverages.reduce(0, +) / Double(sleepService.monthlyAverages.count)
            return "\(Int(average * 100))"
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
                Text("avg monthly score")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)

            // Bar Graph
            HStack(spacing: 4) {
                VStack {
                    Text("100")
                    Spacer()
                    Text("0")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if sleepService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData, barColor: .blue)
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
struct SleepDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let healthStore = HKHealthStore()
            let service = FatigueService()
            let fatigueModel = FatigueModel(service: service)
            SleepDetailView(fatigueModel: fatigueModel)
        }
    }
}

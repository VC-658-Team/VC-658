//
//  HeartRateDetailView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Josh V on 6/10/2025.
//

import SwiftUI
import HealthKit

struct HeartRateDetailView: View {
    @ObservedObject var fatigueModel: FatigueModel
    @StateObject private var heartRateService: HeartRateDataService
    
    init(fatigueModel: FatigueModel) {
        self.fatigueModel = fatigueModel
        // Initialize with the existing health store and resting HR metric from FatigueModel
        let healthStore = fatigueModel.service.healthstore
        let restingHRMetric = fatigueModel.service.calculator.metrics["Resting Heart Rate"] as? RestingHeartRateMetric ?? RestingHeartRateMetric(weight: 3.0, healthStore: healthStore)
        _heartRateService = StateObject(wrappedValue: HeartRateDataService(healthStore: healthStore, restingHRMetric: restingHRMetric))
    }
    
    var body: some View {
        // A TabView is used to create a swipeable interface between different views.
        // The .page style is essential for the watchOS look and feel.
        TabView {
            // Each view placed inside the TabView becomes a separate, swipeable page.
            DailyHeartRateView(heartRateService: heartRateService)
            WeeklyAverageBPMView(heartRateService: heartRateService)
            MonthlyAverageBPMView(heartRateService: heartRateService)
        }
        // This modifier tells the TabView to behave like pages in a book.
        // The indexDisplayMode automatically adds the little dots at the bottom.
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .task {
            // Load all heart rate data when the view appears
            await heartRateService.fetchCurrentHeartRate()
            await heartRateService.fetchDailyHeartRateData()
            await heartRateService.fetchWeeklyAverages()
            await heartRateService.fetchMonthlyAverages()
        }
        .onAppear {
            // Use the current heart rate from FatigueModel if available
            if let restingHRMetric = fatigueModel.service.calculator.metrics["Resting Heart Rate"] as? RestingHeartRateMetric {
                heartRateService.currentHeartRate = restingHRMetric.rawValue
                print("DEBUG: Using existing heart rate data: \(restingHRMetric.rawValue)")
            } else {
                print("DEBUG: No existing heart rate data found")
            }
        }
    }
}

// MARK: - Daily View
// The original content of HeartRateDetailView has been moved into this separate struct
// to keep the code clean and organized.
struct DailyHeartRateView: View {
    // MARK: - Properties
    @ObservedObject var heartRateService: HeartRateDataService
    
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
        heartRateService.dailyHeartRateData.map { CGFloat($0.normalizedValue) }
    }
    
    private var currentBPM: String {
        if heartRateService.isLoading {
            return "--"
        } else if heartRateService.currentHeartRate > 0 {
            return "\(Int(heartRateService.currentHeartRate))"
        } else {
            return "--"
        }
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (Current BPM and Time)
            HStack {
                Text(currentBPM)
                    .font(.system(size: 40, weight: .semibold))
                    .baselineOffset(-4) +
                Text(" bpm")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
            
            }
            .padding(.horizontal)

            // Line Graph
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.blue.opacity(0.6))
                
                if heartRateService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(0.8)
                } else if !graphData.isEmpty {
                    LineGraph(dataPoints: graphData)
                        .stroke(Color.red, lineWidth: 2.5)
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

// MARK: - Preview

struct HeartRateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let healthStore = HKHealthStore()
            let service = FatigueService()
            let fatigueModel = FatigueModel(service: service)
            HeartRateDetailView(fatigueModel: fatigueModel)
        }
    }
}

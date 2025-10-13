//
//  WeeklyAverageBPMView.swift
//  FatigueManagementSystem
//
//  Created by Tom Vo on 6/10/2025.
//

//
//  WeeklyAverageBPMView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 6/10/2025.
//

import SwiftUI
import HealthKit

struct WeeklyAverageBPMView: View {
    // MARK: - Properties
    @ObservedObject var heartRateService: HeartRateDataService
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var graphData: [CGFloat] {
        guard !heartRateService.weeklyAverages.isEmpty else { return [] }
        let maxValue = heartRateService.weeklyAverages.max() ?? 100.0
        let minValue = heartRateService.weeklyAverages.min() ?? 50.0
        let range = maxValue - minValue
        
        return heartRateService.weeklyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var weeklyAverage: String {
        if heartRateService.isLoading {
            return "--"
        } else if !heartRateService.weeklyAverages.isEmpty {
            let average = heartRateService.weeklyAverages.reduce(0, +) / Double(heartRateService.weeklyAverages.count)
            return "\(Int(average))"
        } else {
            return "--"
        }
    }
    
    private var maxBPM: String {
        guard !heartRateService.weeklyAverages.isEmpty else { return "100" }
        let max = heartRateService.weeklyAverages.max() ?? 100.0
        return "\(Int(max))"
    }
    
    private var minBPM: String {
        guard !heartRateService.weeklyAverages.isEmpty else { return "50" }
        let min = heartRateService.weeklyAverages.min() ?? 50.0
        return "\(Int(min))"
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MARK: - Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(weeklyAverage)
                    .font(.system(size: 40, weight: .semibold))
                Text("avg weekly bpm")
                    .font(.headline)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding(.horizontal)

            // MARK: - Bar Graph with Y-Axis Labels
            HStack(spacing: 4) {
                VStack {
                    Text(maxBPM)
                    Spacer()
                    Text(minBPM)
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    if heartRateService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            .scaleEffect(0.8)
                            .frame(height: 60)
                    } else if !graphData.isEmpty {
                        BarGraph(dataPoints: graphData)
                        Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6)) // Baseline
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

// MARK: - Preview
struct WeeklyAverageBPMView_Previews: PreviewProvider {
    static var previews: some View {
        let healthStore = HKHealthStore()
        let restingHRMetric = RestingHeartRateMetric(weight: 3.0, healthStore: healthStore)
        let heartRateService = HeartRateDataService(healthStore: healthStore, restingHRMetric: restingHRMetric)
        WeeklyAverageBPMView(heartRateService: heartRateService)
    }
}

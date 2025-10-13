//
//  MonthlyAverageBPMView.swift
//  FatigueManagementSystem
//
//  Created by Tom Vo on 6/10/2025.
//

//
//  MonthlyAverageBPMView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 6/10/2025.
//

import SwiftUI
import HealthKit

struct MonthlyAverageBPMView: View {
    // MARK: - Properties
    @ObservedObject var heartRateService: HeartRateDataService
    
    private var monthLabels: [(id: String, label: String)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        var labels: [(id: String, label: String)] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let monthLabel = formatter.string(from: date)
                let uniqueId = "\(monthLabel)-\(i)" // Create unique ID
                labels.append((id: uniqueId, label: monthLabel))
            }
        }
        return labels.reversed() // Most recent month first
    }
    
    private var graphData: [CGFloat] {
        guard !heartRateService.monthlyAverages.isEmpty else { return [] }
        let maxValue = heartRateService.monthlyAverages.max() ?? 100.0
        let minValue = heartRateService.monthlyAverages.min() ?? 50.0
        let range = maxValue - minValue
        
        return heartRateService.monthlyAverages.map { value in
            guard range > 0 else { return 0.5 }
            return CGFloat((value - minValue) / range)
        }
    }
    
    private var monthlyAverage: String {
        if heartRateService.isLoading {
            return "--"
        } else if !heartRateService.monthlyAverages.isEmpty {
            let average = heartRateService.monthlyAverages.reduce(0, +) / Double(heartRateService.monthlyAverages.count)
            return "\(Int(average))"
        } else {
            return "--"
        }
    }
    
    private var maxBPM: String {
        guard !heartRateService.monthlyAverages.isEmpty else { return "100" }
        let max = heartRateService.monthlyAverages.max() ?? 100.0
        return "\(Int(max))"
    }
    
    private var minBPM: String {
        guard !heartRateService.monthlyAverages.isEmpty else { return "50" }
        let min = heartRateService.monthlyAverages.min() ?? 50.0
        return "\(Int(min))"
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MARK: - Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(monthlyAverage)
                    .font(.system(size: 40, weight: .semibold))
                Text("avg monthly bpm")
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
                        BarGraph(dataPoints: graphData, barColor: .red)
                        Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6)) // Baseline
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
struct MonthlyAverageBPMView_Previews: PreviewProvider {
    static var previews: some View {
        let healthStore = HKHealthStore()
        let restingHRMetric = RestingHeartRateMetric(weight: 3.0, healthStore: healthStore)
        let heartRateService = HeartRateDataService(healthStore: healthStore, restingHRMetric: restingHRMetric)
        MonthlyAverageBPMView(heartRateService: heartRateService)
    }
}

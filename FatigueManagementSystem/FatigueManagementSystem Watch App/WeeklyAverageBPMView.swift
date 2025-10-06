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

struct WeeklyAverageBPMView: View {
    // MARK: - Properties
    
    // Static mock data for the bar graph shape.
    private let graphData: [CGFloat] = [0.4, 0.5, 0.3, 0.7, 0.8, 0.5, 0.6]
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MARK: - Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("64")
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
                    Text("95")
                    Spacer()
                    Text("55")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    BarGraph(dataPoints: graphData)
                    Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6)) // Baseline
                    
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
        WeeklyAverageBPMView()
    }
}

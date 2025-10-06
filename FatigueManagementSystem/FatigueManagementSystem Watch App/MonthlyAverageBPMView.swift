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

struct MonthlyAverageBPMView: View {
    // MARK: - Properties
    
    // Static mock data for the bar graph shape.
    private let graphData: [CGFloat] = [0.5, 0.55, 0.45, 0.7, 0.6, 0.4, 0.65]
    private let monthLabels = ["Mar", "Apr", "Jun", "Jul", "Aug", "Sep", "Oct"]

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MARK: - Header
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("67")
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
                    Text("100")
                    Spacer()
                    Text("58")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                VStack(spacing: 0) {
                    BarGraph(dataPoints: graphData)
                    Rectangle().frame(height: 1).foregroundColor(.blue.opacity(0.6)) // Baseline
                    
                    HStack {
                        ForEach(monthLabels, id: \.self) { month in
                            Text(month)
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
        MonthlyAverageBPMView()
    }
}

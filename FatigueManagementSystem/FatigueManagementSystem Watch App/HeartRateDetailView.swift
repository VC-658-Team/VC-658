//
//  HeartRateDetailView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Josh V on 6/10/2025.
//

import SwiftUI

struct HeartRateDetailView: View {
    var body: some View {
        // A TabView is used to create a swipeable interface between different views.
        // The .page style is essential for the watchOS look and feel.
        TabView {
            // Each view placed inside the TabView becomes a separate, swipeable page.
            DailyHeartRateView()
            WeeklyAverageBPMView()
            MonthlyAverageBPMView()
        }
        // This modifier tells the TabView to behave like pages in a book.
        // The indexDisplayMode automatically adds the little dots at the bottom.
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

// MARK: - Daily View
// The original content of HeartRateDetailView has been moved into this separate struct
// to keep the code clean and organized.
private struct DailyHeartRateView: View {
    // MARK: - Properties
    
    private let graphData: [CGFloat] = [0.45, 0.6, 0.3, 0.7, 0.85, 0.5, 0.95, 0.4, 0.65]

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

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (Current BPM and Time)
            HStack {
                Text("72")
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
                LineGraph(dataPoints: graphData)
                    .stroke(Color.red, lineWidth: 2.5)
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
                        .font(.headline)
                    Text(dateFormatter.string(from: Date()))
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
            HeartRateDetailView()
        }
    }
}

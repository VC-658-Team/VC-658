//
//  ContentView.swift
//  FatigueTracker Watch App
//
//  Created by Josh on 9/9/2025.
//

import SwiftUI

struct ContentView: View {
    // CHANGED: Converted to @State variables to allow dynamic updates
    @State private var stressLevel: Double = 0.65
    @State private var stressValue: Int = 1
    
    // ADDED: A computed property to change the gauge color based on the stress level
    private var gaugeColor: Color {
        if stressLevel <= 0.4 {
            return .green
        } else if stressLevel <= 0.75 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 7) {
                // MARK: - Header with Settings Button
                HStack {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal)

                // MARK: - Gauge
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 16)
                        .rotationEffect(.degrees(180))

                    Circle()
                        .trim(from: 0, to: stressLevel * 0.5)
                        // CHANGED: The stroke color now uses the dynamic gaugeColor
                        .stroke(gaugeColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(180))

                    VStack(spacing: 0) {
                        Text("\(stressValue)")
                            .font(.system(size: 42, weight: .bold))
                        Text("Stress")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 12)
                }
                .frame(width: 115, height: 85)
                .padding(.bottom, 8)

                // MARK: - Metrics List
                VStack {
                    MetricRowView(iconName: "heart.fill", iconColor: .red, title: "72 bpm")
                    MetricRowView(iconName: "bed.double.fill", iconColor: .blue, title: "7h 30m")
                    MetricRowView(iconName: "clock.fill", iconColor: .yellow, title: "8h 15m")
                }
                .padding(.horizontal)
                
                Spacer(minLength: 1)
            }
            .padding(.top, 5)
            // ADDED: This modifier runs code when the view first appears
            .onAppear {
                // This timer fires every 2 seconds to simulate live data updates
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    // 'withAnimation' makes the change smooth instead of sudden
                    withAnimation(.easeInOut(duration: 1.0)) {
                        let newStressValue = Int.random(in: 10...100)
                        self.stressValue = newStressValue
                        // Convert the Int score (10-100) to a Double for the gauge (0.1-1.0)
                        self.stressLevel = Double(newStressValue) / 100.0
                    }
                }
            }
        }
    }
}
// Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 2/9/2025.
//
import SwiftUI
import HealthKit
struct ContentView: View {
    @StateObject private var viewModel: FatigueModel
    @StateObject private var settingsManager = SettingsManager.shared
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
    
    init(service: FatigueService) {
        _viewModel = StateObject(wrappedValue: FatigueModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            
//            if !viewModel.authorised {
            
//            Text("fetching data")
                VStack(spacing: 6) {
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
                                .padding(.bottom, 4)
                        }
                        .offset(y: 12)
                    }
                    .frame(width: 115, height: 85)
                    .padding(.bottom, 8)
                    
                    // MARK: - Metrics List
                    VStack {
                        // Dynamic metrics based on settings
                        if settingsManager.isMetricEnabled(.heartRate) {
                            NavigationLink(destination: HeartRateDetailView(fatigueModel: viewModel)) {
                                MetricRowView(iconName: MetricType.heartRate.iconName, iconColor: MetricType.heartRate.iconColor, title: viewModel.restingHRString)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if settingsManager.isMetricEnabled(.sleep) {
                            NavigationLink(destination: SleepDetailView(fatigueModel: viewModel)) {
                                MetricRowView(iconName: MetricType.sleep.iconName, iconColor: MetricType.sleep.iconColor, title: viewModel.sleepString)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if settingsManager.isMetricEnabled(.steps) {
                            NavigationLink(destination: StepsDetailView(fatigueModel: viewModel)) {
                                MetricRowView(iconName: MetricType.steps.iconName, iconColor: MetricType.steps.iconColor, title: viewModel.stepsString)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if settingsManager.isMetricEnabled(.calories) {
                            NavigationLink(destination: CaloriesDetailView(fatigueModel: viewModel)) {
                                MetricRowView(iconName: MetricType.calories.iconName, iconColor: MetricType.calories.iconColor, title: viewModel.caloryString)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 0.5)
                }
                .padding(.top, 5)
                // ADDED: This modifier runs code when the view first appears
                .onAppear {
                    viewModel.getFatigueScore()
                        
                }.onReceive(viewModel.$fatigueScore) { score in
                    // 'withAnimation' makes the change smooth instead of sudden
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.stressValue = score
                        // Convert the Int score (10-100) to a Double for the gauge (0.1-1.0)
                        self.stressLevel = Double(self.stressValue) / 100.0
                    }
                }
                            
            }
        }
    }

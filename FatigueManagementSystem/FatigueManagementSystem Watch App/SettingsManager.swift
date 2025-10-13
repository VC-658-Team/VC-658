//
//  SettingsManager.swift
//  FatigueManagementSystem Watch App
//
//  Created by AI Assistant on 2/9/2025.
//

import Foundation
import SwiftUI

/// Manages user settings for the app
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var enabledMetrics: Set<MetricType> = [.heartRate, .sleep, .steps, .calories]
    @Published var areAlertsEnabled: Bool = true
    @Published var areHapticsEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let enabledMetrics = "enabled_metrics"
        static let areAlertsEnabled = "are_alerts_enabled"
        static let areHapticsEnabled = "are_haptics_enabled"
    }
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Metric Management
    
    func isMetricEnabled(_ metric: MetricType) -> Bool {
        return enabledMetrics.contains(metric)
    }
    
    func toggleMetric(_ metric: MetricType) {
        if enabledMetrics.contains(metric) {
            enabledMetrics.remove(metric)
        } else {
            enabledMetrics.insert(metric)
        }
        saveSettings()
    }
    
    func setMetricEnabled(_ metric: MetricType, enabled: Bool) {
        if enabled {
            enabledMetrics.insert(metric)
        } else {
            // Ensure at least one metric is always enabled
            if enabledMetrics.count > 1 {
                enabledMetrics.remove(metric)
            }
        }
        saveSettings()
    }
    
    // MARK: - Settings Management
    
    func setAlertsEnabled(_ enabled: Bool) {
        areAlertsEnabled = enabled
        saveSettings()
    }
    
    func setHapticsEnabled(_ enabled: Bool) {
        areHapticsEnabled = enabled
        saveSettings()
    }
    
    // MARK: - Persistence
    
    private func loadSettings() {
        // Load enabled metrics
        if let data = userDefaults.data(forKey: Keys.enabledMetrics),
           let metrics = try? JSONDecoder().decode(Set<MetricType>.self, from: data) {
            enabledMetrics = metrics
        }
        
        // Load other settings
        areAlertsEnabled = userDefaults.bool(forKey: Keys.areAlertsEnabled)
        areHapticsEnabled = userDefaults.bool(forKey: Keys.areHapticsEnabled)
    }
    
    private func saveSettings() {
        // Save enabled metrics
        if let data = try? JSONEncoder().encode(enabledMetrics) {
            userDefaults.set(data, forKey: Keys.enabledMetrics)
        }
        
        // Save other settings
        userDefaults.set(areAlertsEnabled, forKey: Keys.areAlertsEnabled)
        userDefaults.set(areHapticsEnabled, forKey: Keys.areHapticsEnabled)
    }
}

// MARK: - Supporting Types

enum MetricType: String, CaseIterable, Codable {
    case heartRate = "heartRate"
    case sleep = "sleep"
    case steps = "steps"
    case calories = "calories"
    
    var displayName: String {
        switch self {
        case .heartRate:
            return "Heart Rate"
        case .sleep:
            return "Sleep"
        case .steps:
            return "Steps"
        case .calories:
            return "Calories"
        }
    }
    
    var iconName: String {
        switch self {
        case .heartRate:
            return "heart.fill"
        case .sleep:
            return "bed.double.fill"
        case .steps:
            return "figure.walk"
        case .calories:
            return "flame.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .heartRate:
            return .red
        case .sleep:
            return .blue
        case .steps:
            return .green
        case .calories:
            return .orange
        }
    }
}

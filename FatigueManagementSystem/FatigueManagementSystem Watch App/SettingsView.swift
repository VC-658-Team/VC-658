//
//  SettingsView.swift
//  FatigueTracker
//
//  Created by Josh on 9/9/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // MARK: - App Settings Section (No Header)
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Enable Alerts", isOn: Binding(
                        get: { settingsManager.areAlertsEnabled },
                        set: { settingsManager.setAlertsEnabled($0) }
                    ))
                    
                    Toggle("Enable Haptics", isOn: Binding(
                        get: { settingsManager.areHapticsEnabled },
                        set: { settingsManager.setHapticsEnabled($0) }
                    ))
                }
                .padding(.bottom, 10)
                
                Divider()
                
                // MARK: - Metric Selection Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Displayed Metrics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        HStack {
                            Image(systemName: metric.iconName)
                                .foregroundColor(metric.iconColor)
                                .frame(width: 20)
                            
                            Text(metric.displayName)
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { settingsManager.isMetricEnabled(metric) },
                                set: { settingsManager.setMetricEnabled(metric, enabled: $0) }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

// Preview for the SettingsView
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // We embed it in a NavigationStack for the preview to show the title
        NavigationStack {
            SettingsView()
        }
    }
}

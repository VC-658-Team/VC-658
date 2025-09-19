//
//  SettingsView.swift
//  FatigueTracker
//
//  Created by Josh on 9/9/2025.
//

import SwiftUI

struct SettingsView: View {
    // @State variables to hold the toggle states.
    // The state is saved only while the app is running.
    @State private var areAlertsEnabled: Bool = true
    @State private var areHapticsEnabled: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // A toggle is a standard UI element for on/off switches.
            Toggle("Enable Alerts", isOn: $areAlertsEnabled)
            
            Toggle("Enable Haptics", isOn: $areHapticsEnabled)
            
            Spacer()
        }
        // Adds a title to the top of the settings screen.
        .navigationTitle("Settings")
        // Adds a little padding from the screen edges.
        .padding()
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

//
//  FatigueManagementSystemApp.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 2/9/2025.
//

import SwiftUI
import HealthKit
@main
struct FatigueManagementSystem_Watch_AppApp: App {
    init() {
        FatigueService.service.start()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


//
//  FatigueManagementSystemApp.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 2/9/2025.
//

import SwiftUI
import HealthKit
@main
struct FatigueManagementSystemWatchApp: App {
    let service = FatigueService()
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    @State private var ready = false
    init() {
        extensionDelegate.fatigueService = service
    }
    var body: some Scene {
        WindowGroup {
            if ready {
                ContentView(service: service)
                
            } else {
                LoadingView()
                    .task {
                        let success = await withCheckedContinuation { continuation in
                            service.start { ready in
                                continuation.resume(returning: ready)
                            }
                        }
                        ready = success
                    }
            }
        }
    }
}

//
//  ExtensionDelegate.swift
//  FatigueManagementSystem
//
//  Created by Apple on 17/10/2025.
//

import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var fatigueService: FatigueService!
    
    func applicationDidFinishLaunching() {
    }

    func applicationDidBecomeActive() {
    }

    func applicationWillResignActive() {
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
            for task in backgroundTasks {
                if let refreshTask = task as? WKApplicationRefreshBackgroundTask,
                   let userInfo = refreshTask.userInfo as? String,
                   userInfo == fatigueService.fatigueTaskID {
                        fatigueService.calculateScore {
                            refreshTask.setTaskCompletedWithSnapshot(true)
                        }
                } else {
                    task.setTaskCompletedWithSnapshot(true)
                }
            }
        }
}

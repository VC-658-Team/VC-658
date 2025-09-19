//
//  ContentView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 2/9/2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var fatigueScore: Int = 0
    @State private var restingHR: Double = 65.0
    
    
    var body: some View {
        VStack {
            Text("Resting HR: \(Int(restingHR)) bpm")
                .font(.headline)
            
            Text("Fatigue Score: \(fatigueScore)")
                .font(.largeTitle)
                .padding()
            //Image(systemName: "globe")  initial project hello world settings
              //  .imageScale(.large)
                //.foregroundStyle(.tint)
            //Text("Hello, world!")
        }
        .onAppear {
            testRestingHRMetric()
        }
        //.padding()
    }
    
    func testRestingHRMetric() {
        let healthStore = HKHealthStore()
        
        let rhrMetric = RestingHeartRateMetric(weight: 1.0, healthStore: healthStore, rawValue: restingHR)
        
        let normalised = rhrMetric.normalisedValue()
        
        fatigueScore = Int(normalised * 100)
        
    }
}

#Preview {
    ContentView()
}

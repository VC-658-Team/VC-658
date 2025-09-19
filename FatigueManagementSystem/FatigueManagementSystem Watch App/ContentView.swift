//
//  ContentView.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 2/9/2025.
//

import SwiftUI
import HealthKit



//struct ContentView: View {
 //   @State private var fatigueScore: Int = 0
//    @State private var restingHR: Double = 65.0
    
    
//    var body: some View {
//        VStack {
//            Text("Resting HR: \(Int(restingHR)) bpm")
//                .font(.headline)
            
//            Text("Fatigue Score: \(fatigueScore)")
//                .font(.largeTitle)
//                .padding()
            //Image(systemName: "globe")  initial project hello world settings
              //  .imageScale(.large)
                //.foregroundStyle(.tint)
            //Text("Hello, world!")
//        }
//        .onAppear {
//            testRestingHRMetric()
//        }
        //.padding()
//    }
    
//    func testRestingHRMetric() {
//        let healthStore = HKHealthStore()
        
//        let rhrMetric = RestingHeartRateMetric(weight: 1.0, healthStore: healthStore)
        
//        let normalised = rhrMetric.normalisedValue()
        
//        fatigueScore = Int(normalised * 100)
        
//    }
//}

//#Preview {
//    ContentView()
//}


struct ContentView: View {
    let rhrMetric = RestingHeartRateMetric()
    
    @State private var fatiguePercentage: Double?
    
    var body: some View {
        VStack {
            if let fatigue = fatiguePercentage {
                Text("Fatigue Score: \(Int(fatigue))%")
                    .font(.title)
        
            } else{
                Text("fething data")
            }
        }
        .onAppear {
            rhrMetric.requestAuthorization { success in
                if success {
                    rhrMetric.fetchLatest { bpm in
                        guard let bpm = bpm else { return }
                        let normalized = rhrMetric.normalize(_value: bpm)
                        
                        FatigueCalculatormp.shared.addMetric(name: "RestingHeartRate", value: normalized)
                        let score = FatigueCalculatormp.shared.calculateFatigue()
                        
                        DispatchQueue.main.async {
                            fatiguePercentage = score * 100
                        }
                        
                        
                    }
                }}
        }
    }
}

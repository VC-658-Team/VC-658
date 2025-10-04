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


// struct ContentView: View {
//     let rhrMetric = RestingHeartRateMetric()
    
//     @State private var fatiguePercentage: Double?
    
//     var body: some View {
//         VStack {
//             if let fatigue = fatiguePercentage {
//                 Text("Fatigue Score: \(Int(fatigue))%")
//                     .font(.title)
        
//             } else{
//                 Text("fething data")
//             }
//         }
//         .onAppear {
//             rhrMetric.requestAuthorization { success in
//                 if success {
//                     rhrMetric.fetchLatest { bpm in
//                         guard let bpm = bpm else { return }
//                         let normalized = rhrMetric.normalize(_value: bpm)
                        
//                         FatigueCalculatormp.shared.addMetric(name: "RestingHeartRate", value: normalized)
//                         let score = FatigueCalculatormp.shared.calculateFatigue()
                        
//                         DispatchQueue.main.async {
//                             fatiguePercentage = score * 100
//                         }
                        
                        
//                     }
//                 }}
//         }
//     }
// }


struct ContentView: View {
    @StateObject private var viewModel: FatigueModel
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
            if (true){
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
                        MetricRowView(iconName: "heart.fill", iconColor: .red, title: viewModel.restingHRString)
                        MetricRowView(iconName: "bed.double.fill", iconColor: .blue, title: viewModel.sleepString)
                        MetricRowView(iconName: "figure.walk", iconColor: .green, title: viewModel.stepsString)
                        MetricRowView(iconName: "flame.fill", iconColor: .orange, title: viewModel.caloryString)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 1)
                }
                .padding(.top, 5)
                // ADDED: This modifier runs code when the view first appears
                .onAppear {
                    viewModel.getFatigueScore()
                        
                }.onReceive(viewModel.$fatigueScore) { score in
                    // 'withAnimation' makes the change smooth instead of sudden
                    withAnimation(.easeInOut(duration: 1.0)) {
                        //let newStressValue = Int.random(in: 10...100)
                        self.stressValue = score
                        // Convert the Int score (10-100) to a Double for the gauge (0.1-1.0)
                        self.stressLevel = Double(self.stressValue) / 100.0
                    }
                }
                            
            }
        }
    }
}
//// Previews
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

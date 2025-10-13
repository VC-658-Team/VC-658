import Foundation
import UserNotifications

class DefaultFatigueCalculator: FatigueCalculator {
    var metrics: [String: FatigueMetric]
     
     var fatigueScore: Int = 0
         
     // Store metrics as a key-value pair dictionary
     init() {
         metrics = [:]
     }
     // Add metric to dictionary using key parameter
     func addMetric(key: String, value: any FatigueMetric) {
         metrics.updateValue(value, forKey: key)
     }
    
     // Return selected metric using key parameter
     // check if metric is not set
     func getMetric(key: String) -> any FatigueMetric {
         return metrics[key]!
     }
    
     // Calculate fatigue score
     func calculateScore(completion: @escaping () -> Void) {
         let allMetrics = Array(metrics.values)
         guard !allMetrics.isEmpty else {
             completion()
             return
             
         }
         let group = DispatchGroup()
         
         for metric in allMetrics {
             group.enter()
             metric.getRawValue {
                 print("Values: \(metric.name) raw=\(metric.rawValue), norm=\(metric.normalisedValue())")
                 
                 group.leave()
             }
         }
         group.notify(queue: .main) { [weak self] in
             guard let self = self else {
                 completion()
                 return
             }
             
             let totalWeight = allMetrics.map { $0.weight }.reduce(0, +)
             guard totalWeight > 0 else {
                 completion()
                 return
             }
             
             let weightedTotal = allMetrics.map { $0.weightedScore() }.reduce(0, +)
             self.fatigueScore = Int((weightedTotal / totalWeight) * 100)

             completion()
         }
     }
     
     func getFatigueScore() -> Int {
         return FatigueScore
     }
     
 }

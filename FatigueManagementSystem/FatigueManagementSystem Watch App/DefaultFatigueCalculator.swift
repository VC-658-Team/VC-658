import Foundation
import UserNotifications
//
//class DefaultFatigueCalculator {
//    static let shared = DefaultFatigueCalculator()
//    private var metrics: [String: Double] = [:]
//    
//    func addMetric(name: String, value: Double) {
//        metrics[name] = value
//    }
//    
//    func calculateFatigue() -> Double {
//        let sum = metrics.values.reduce(0, +)
//        return sum / Double(metrics.count)
//    }
//}


 class DefaultFatigueCalculator: FatigueCalculator {
     var Metrics: Dictionary<String, any FatigueMetric>
         
     // Store metrics as a key-value pair dictionary
     init() {
         Metrics = [:]
     }
    
     // Add metric to dictionary using key parameter
     func addMetric(key: String, value: any FatigueMetric) {
         Metrics.updateValue(value, forKey: key)
     }
    
     // Return selected metric using key parameter
     // TODO: check if metric is not set
     func GetMetric(key: String) -> any FatigueMetric {
         return Metrics[key]!
     }
    
    
     // Calculate fatigue score
     func getFatigueScore() -> Int {
         let allMetrics = Array(Metrics.values)
         
         //fixing the normalised values
         for metric in allMetrics {
             print("DEBUG: \(metric.name) raw=\(metric.rawValue), norm=\(metric.normalisedValue())")
         }
         
         let totalWeight = allMetrics.map { $0.weight }.reduce(0, +)
         guard totalWeight > 0 else { return 0}
         let weightedTotal = allMetrics.map { $0.weightedScore()}.reduce(0, +)
         return Int((weightedTotal / totalWeight) * 100)
     }
     
 }

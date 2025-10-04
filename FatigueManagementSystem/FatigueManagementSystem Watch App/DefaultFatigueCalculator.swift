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
     
     var FatigueScore: Int = 0
         
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
     func CalculateScore(completion: @escaping () -> Void) {
         let allMetrics = Array(Metrics.values)
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
             self.FatigueScore = Int((weightedTotal / totalWeight) * 100)

             completion()
         }
     }
     
 }

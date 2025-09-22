import Foundation

class FatigueCalculatorImp: FatigueCalculator {
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
    func GetMetric(key: String) -> any FatigueMetric {
        return Metrics[key]!
    }
    
    
    // Calculate fatigue score
    func getFatigueScore() -> Int {
        let allMetrics = Array(Metrics.values)
        
        let totalWeight = allMetrics.map { $0.weight }.reduce(0, +)
        guard totalWeight > 0 else { return 0}
    
        let weightedTotal = allMetrics.map { $0.weightedScore()}.reduce(0, +)
        
        return Int((weightedTotal / totalWeight) * 100)
    }
}

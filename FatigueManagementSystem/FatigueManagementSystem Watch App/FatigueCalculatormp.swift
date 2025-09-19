import Foundation

class FatigueCalculatorImp: FatigueCalculator {

    var Metrics: Dictionary<String, any FatigueMetric>
    
    init() {
        Metrics = [:]
    }
    
    func addMetric(key: String, value: any FatigueMetric) {
        Metrics.updateValue(value, forKey: key)
    }
    
    func GetMetric(key: String) -> FatigueMetric {
        return Metrics[key]!
    }
    
    
    func getFatigueScore() -> Int {
        let allMetrics = Array(Metrics.values)
        
        let totalWeight = allMetrics.map { $0.weight }.reduce(0, +)
        guard totalWeight > 0 else { return 0}
    
        let weightedTotal = allMetrics.map { $0.weightedScore()}.reduce(0, +)
        
        return Int((weightedTotal / totalWeight) * 100)
    }
}

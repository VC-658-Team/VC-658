import Foundation

protocol FatigueCalculator {
    
    var Metrics: Dictionary<String, FatigueMetric> { get }
    
    func addMetric(key: String, value: FatigueMetric)-> Void
    
    func getFatigueScore() -> Int
    
    func GetMetric(key: String) -> FatigueMetric
    
}

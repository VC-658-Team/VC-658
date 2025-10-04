import Foundation

protocol FatigueCalculator {
    
    var Metrics: Dictionary<String, any FatigueMetric> { get }
    
    func addMetric(key: String, value: any FatigueMetric)-> Void
    
    func getFatigueScore() -> Int
    
    func GetMetric(key: String) -> any FatigueMetric
    
}

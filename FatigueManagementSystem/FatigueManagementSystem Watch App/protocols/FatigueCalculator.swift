import Foundation

protocol FatigueCalculator {
    
    var FatigueScore : Int { get }
    
    var Metrics: Dictionary<String, FatigueMetric> { get }
    
    func addMetric(key: String, value: FatigueMetric)-> Void
    
    func CalculateScore()
    
    func GetMetric(key: String) -> FatigueMetric
    
}

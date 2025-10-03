import Foundation

protocol FatigueCalculator {
    
    var FatigueScore : Int { get }
    
    var Metrics: Dictionary<String, FatigueMetric> { get }
    
    func addMetric(key: String, value: FatigueMetric)-> Void
    
    func CalculateScore(completion: @escaping () -> Void)

    func GetMetric(key: String) -> FatigueMetric
    
}

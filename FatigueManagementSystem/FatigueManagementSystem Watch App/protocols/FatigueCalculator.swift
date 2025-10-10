import Foundation

protocol FatigueCalculator {
    
    var fatigueScore: Int { get }
    
    var Metrics: Dictionary<String, any FatigueMetric> { get }
    
    func addMetric(key: String, value: any FatigueMetric)-> Void
    
    func getFatigueScore() -> Int
    
    func CalculateScore(completion: @escaping () -> Void)

    func GetMetric(key: String) -> any FatigueMetric
    
}

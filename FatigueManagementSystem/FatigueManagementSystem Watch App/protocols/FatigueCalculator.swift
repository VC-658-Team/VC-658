import Foundation

protocol FatigueCalculator {
    
    var fatigueScore: Int { get }
    
    var Metrics: Dictionary<String, any FatigueMetric> { get }

    func addMetric(key: String, value: FatigueMetric)
    
    func addMetric(key: String, value: any FatigueMetric)-> Void
    
    func getFatigueScore() -> Int
    
    func calculateScore(completion: @escaping () -> Void)

    func getMetric(key: String) -> FatigueMetric
    
}

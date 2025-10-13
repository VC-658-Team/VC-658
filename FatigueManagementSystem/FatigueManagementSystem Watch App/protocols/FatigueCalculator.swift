import Foundation

protocol FatigueCalculator {
    
    var fatigueScore: Int { get }
    
    var metrics: [String: FatigueMetric] { get }

    func addMetric(key: String, value: FatigueMetric)
        
    func getFatigueScore() -> Int
    
    func calculateScore(completion: @escaping () -> Void)

    func getMetric(key: String) -> FatigueMetric
    
}

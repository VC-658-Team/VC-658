import Foundation

protocol FatigueMetric {
    
    // Used to retrieve locally stored data about metric, such as baselines
    var name: String { get }
    // Weight in relation to indication of fatigue
    var weight: Double { get }
    // Raw value of metric (hours of sleep, current heart rate, ect)
    var rawValue: Double { get }

    // Minimum possible value of metric ( 0 hours of sleep)
    var minValue: Double { get }

    // Maximum possible value of metric
    var maxValue: Double { get }

    // Is set separately, value must come either from local storage of calculated if not currently stored
    var baseline: Double {get set}

    // Normalised value, between 0-1, of current level
    /* Example Implementation
        return max(0, min(1, baseline / rawValue))

    */
    func normalisedValue(baseline: Double) -> Double
    
    // Used to calculate the baseline if it does not exist in local storage
    func calculateBaseline() -> Void
    
}

extension FatigueMetric {
    func weightedScore() -> Double {
        return normalisedValue() * weight
    }
    
}


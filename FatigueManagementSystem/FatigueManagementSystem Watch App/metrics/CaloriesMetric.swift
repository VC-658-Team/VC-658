import Foundation
import HealthKit

class CaloriesMetric: FatigueMetric {
    
    let name = "calories"
    let weight: Double
    var baseline: Double
    var rawValue: Double
    let healthStore: HKHealthStore
    private let localDataManager = LocalDataManager.shared
        
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight
        self.baseline = 500.0
        self.rawValue = 0.0
        self.healthStore = healthStore
        
        self.baseline = localDataManager.getBaseline(for: "calories") ?? 500.0
        self.rawValue = 0.0
        
        self.getRawValue {
            if self.localDataManager.shouldUpdateBaseline(for: "calories") {
                self.calculateBaseline()
            }
        }
    }
    
    func getRawValue(completion: @escaping () -> Void) {
        self.getTodayCalories { [weak self] calories in
            self?.rawValue = calories
            completion()
        }
    }
    
    func getTodayCalories(completion: @escaping (Double) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            
            DispatchQueue.main.async {
                completion(calories)
            }
        }
        
        self.healthStore.execute(query)
    }
    
    func calculateBaseline() {
        self.getHistoricalCaloriesData { dailyCalories in
            if !dailyCalories.isEmpty {
                let totalCalories = dailyCalories.reduce(0, +)
                self.baseline = totalCalories / Double(dailyCalories.count)
            } else {
                self.baseline = 500.0
            }
        }
    }
    
    func getHistoricalCaloriesData(completion: @escaping ([Double]) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        var dailyCalories: [Double] = []
        let calendar = Calendar.current
        let endDate = Date()
        let numberOfDays = 30
        
        let group = DispatchGroup()
        
        for day in 1..<numberOfDays {
            guard let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: caloriesType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                dailyCalories.append(calories)
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(dailyCalories)
        }
    }
    
    func normalisedValue() -> Double {
        guard baseline > 0 else { return 0.0 }
        guard rawValue > 0 else { return rawValue }
        // More calories burned = more exertion = more fatigue
        let deviation = (rawValue - baseline) / baseline
        return max(-1, min(1, deviation))
    }
}

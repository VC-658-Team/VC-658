import Foundation
import HealthKit

class StepsMetric: FatigueMetric {
    
    let name = "steps"
    let weight: Double
    var baseline: Double
    var rawValue: Double
    
    let healthStore: HKHealthStore
    private let localDataManager = LocalDataManager.shared
    
    init(weight: Double, healthStore: HKHealthStore) {
        self.weight = weight
        self.healthStore = healthStore
        
        self.baseline = localDataManager.getBaseline(for: "steps") ?? 10000.0
        self.rawValue = 0.0
        
        self.getRawValue {
            if self.localDataManager.shouldUpdateBaseline(for: "steps") {
                self.calculateBaseline()
            }
        }
    }
    
    func getRawValue(completion: @escaping () -> Void) {
        self.rawValue = 0.0
        
        self.getTodaySteps { [weak self] steps in
            self?.rawValue = Double(steps)
            completion()
        }
    }
    
    func getTodaySteps(completion: @escaping (Int) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            
            DispatchQueue.main.async {
                completion(Int(steps))
            }
        }
        
        self.healthStore.execute(query)
    }
    
    func calculateBaseline() {
        self.getHistoricalStepsData { dailySteps in
            if !dailySteps.isEmpty {
                let totalSteps = dailySteps.reduce(0, +)
                let newBaseline = Double(totalSteps / dailySteps.count)
                
                self.baseline = newBaseline
                self.localDataManager.saveBaseline(for: "steps", value: newBaseline)
            } else {
                let defaultBaseline = 10000.0
                self.baseline = defaultBaseline
                self.localDataManager.saveBaseline(for: "steps", value: defaultBaseline)
            }
        }
    }
    
    func getHistoricalStepsData(completion: @escaping ([Int]) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        var dailySteps: [Int] = []
        let calendar = Calendar.current
        let endDate = Date()
        let numberOfDays = 30
        
        let group = DispatchGroup()
        
        for i in 0..<numberOfDays {
            guard let dayStart = calendar.date(byAdding: .day, value: -i, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                dailySteps.append(Int(steps))
                group.leave()
            }
            
            self.healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(dailySteps)
        }
    }
    
    func normalisedValue() -> Double {
        guard baseline > 0 else { return 0.0 }
        
        // More steps = more exertion = more fatigue
        let deviation = (rawValue - baseline) / baseline
        return max(0, min(1, deviation))
    }
}
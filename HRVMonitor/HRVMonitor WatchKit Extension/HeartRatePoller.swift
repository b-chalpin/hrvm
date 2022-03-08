//
//  HeartRatePoller.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/7/22.
//

import Foundation
import HealthKit

let HR_WINDOW_SIZE = 15

public class HeartRatePoller {
    private let healthStore: HKHealthStore
    private var hrStore: [Double]
    
    public init() {
        self.healthStore = HKHealthStore()
        // if unsuccesful in polling heart rate, hrStore will be nil
        self.hrStore = []
    }
    
    public func getHeartRateWindow() -> [Double] {
        self.queryHeartRateSampleWindow()
        return self.hrStore
    }
    
    private func queryHeartRateSampleWindow() {
        if (HKHealthStore.isHealthDataAvailable()) {
            let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            
            self.healthStore.requestAuthorization(toShare:nil, read:[heartRateType], completion:{(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)

                let query = HKSampleQuery(sampleType:heartRateType, predicate:nil, limit:HR_WINDOW_SIZE, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    guard let results = results else {
                        print("ERROR - query results are empty")
                        return
                    }
                    
                    // we will store the new heart rate samples in self.hrStore
                    self.hrStore = results.map { (sample) -> Double in
                        let quantity = (sample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        return quantity.doubleValue(for: heartRateUnit)
                    }
                })
                self.healthStore.execute(query)
                
                print("Executed heart rate query. Resutls:\n\(self.hrStore)")
            })
        }
        else {
            print("ERROR - Health data is not available")
        }
    }
}

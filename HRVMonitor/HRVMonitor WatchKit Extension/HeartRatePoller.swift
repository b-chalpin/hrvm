//
//  HeartRatePoller.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/7/22.
//

import Foundation
import HealthKit

let HR_WINDOW_SIZE = 15
let HR_STORE_SIZE = 60
let HRV_STORE_SIZE = 15

public class HeartRatePoller {
    private let healthStore: HKHealthStore
    private var hrStore: [HRItem]
    private var hrvStore: [HRItem]
    
    public init() {
        self.healthStore = HKHealthStore()
        self.hrStore = []
        self.hrvStore = []
    }
    
    public func getLatestHrValue() -> Double {
        if self.hrStore.count == 0 {
            print("HRStore is empty")
            return 100.0
        }
        
        return self.hrStore.last!.value
    }
    
    public func getLatestHrvValue() -> Double {
        if self.hrvStore.count == 0 {
            print("HRVStore is empty")
            return 100.0
        }
        
        return self.hrvStore.last!.value
    }
    
    
    public func getHrStore() -> [HRItem] {
        return self.hrStore
    }
    
    public func getHrvStore() -> [HRItem] {
        return self.hrvStore
    }
    
    public func pollHeartRate() {
        print("hit")
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
                    
                    if results.count == 0 {
                        print("No records returned for heart rate")
                        return
                    }
                    
                    // we will store the new heart rate samples in self.hrStore
                    let newHRSamples = results.map { (sample) -> HRItem in
                        let quantity = (sample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        
                        let heartRateBpm = quantity.doubleValue(for: heartRateUnit)
                        let heartRateTimestamp = sample.endDate
                        
                        return HRItem(value:heartRateBpm, timestamp: heartRateTimestamp)
                    }
                    
                    print("Samples received\n\(newHRSamples)")
                    
                    let newHrv = self.calculateHrv(hrSamples:newHRSamples)
                    
                    // add new samples to hrStore
                    // for now just reassign the hrStore
                    self.hrStore = newHRSamples
                    
                    // add new Hrv to store
                    self.addHrvToHrvStore(newHrv: newHrv)
                })
                self.healthStore.execute(query)
                
                print("Executed heart rate query. Results:\n\(self.hrStore)")
            })
        }
        else {
            print("ERROR - Health data is not available")
        }
    }
    
    private func calculateHrv(hrSamples: [HRItem]) -> HRItem {
        let hrSamplesInMS = hrSamples.map { (sample) -> Double in
            // convert bpm -> ms
            return 60_000 / sample.value
        }
        
        let hrvInMS = self.calculateStdDev(samples: hrSamplesInMS)
        print("Samples \(hrSamplesInMS) -- std dev: \(hrvInMS)")
        let hrvTimestamp = hrSamples.last!.timestamp
        
        return HRItem(value:hrvInMS, timestamp: hrvTimestamp)
    }
    
    private func calculateStdDev(samples: [Double]) -> Double {
        let length = Double(samples.count)
        let avg = samples.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = samples.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    private func addSamplesToHrStore(newHRSamples: [HRItem]) {
        // add new samples and remove duplicates
        // diff = calculate new size - HR_STORE_SIZE
        // remove the first <diff> items in store
    }
    
    private func addHrvToHrvStore(newHrv: HRItem) {
        if self.hrvStore.count == HRV_STORE_SIZE {
            self.hrvStore.removeFirst()
        }
        self.hrvStore.append(newHrv)
    }
}

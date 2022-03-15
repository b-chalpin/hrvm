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

public class HeartRatePoller : ObservableObject {
    // constants
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let healthStore: HKHealthStore = HKHealthStore()
    
    // variables
    private var hrStore: [HRItem]
    private var hrvStore: [HRItem]
    
    // UI will be subscribed to this
    @Published var latestHrv: HRItem?
    
    // boolean flag to determine if still gathering initial HRV samples
    @Published var initializingHrvMonitor: Bool = true
    
    // auth status
    @Published var authStatus: HKAuthorizationStatus = .notDetermined
    
    public init() {
        self.hrStore = []
        self.hrvStore = []
        
        self.requestAuthorization()
    }
    
    public func getHrStore() -> [HRItem] {
        return self.hrStore
    }
    
    public func getHrvStore() -> [HRItem] {
        return self.hrvStore
    }
    
    private func updateAuthStatus() {
        authStatus = healthStore.authorizationStatus(for: self.heartRateQuantityType)
    }
    
    private func requestAuthorization() {
        let sharing = Set<HKSampleType>()
        let reading = Set<HKObjectType>([self.heartRateQuantityType])
        healthStore.requestAuthorization(toShare: sharing, read: reading) { [weak self] result, error in
            if result {
                DispatchQueue.main.async {
                    self?.updateAuthStatus()
                }
            } else if let error = error {
                print("Auth failed: \(error.localizedDescription)")
            } else {
                fatalError("Fatal error occurred when requesting Health Store authorization")
            }
        }
    }
    
    public func poll() {
        if (HKHealthStore.isHealthDataAvailable()) {
            let sortByTimeDescending = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: self.heartRateQuantityType, predicate: nil, limit:HR_WINDOW_SIZE, sortDescriptors: [sortByTimeDescending], resultsHandler: { (query, results, error) in
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
                
                // list of new samples
                let newHRSamples = results.map { (sample) -> HRItem in
                    let quantity = (sample as! HKQuantitySample).quantity
                    let heartRateUnit = HKUnit(from: "count/min")
                    
                    let heartRateBpm = quantity.doubleValue(for: heartRateUnit)
                    let heartRateTimestamp = sample.endDate
                    
                    return HRItem(value: heartRateBpm, timestamp: heartRateTimestamp)
                }
                
                let newHrv = self.calculateHrv(hrSamples: newHRSamples)
                
                DispatchQueue.main.async {
                    // update subscribed views with new hrv
                    self.latestHrv = newHrv

                    print("HRV UPDATED: \(self.latestHrv!.value)")
                }
                
                // add new samples to hrStore
                // for now just reassign the hrStore
                self.hrStore = newHRSamples
                
                // add new Hrv to store
                self.addHrvToHrvStore(newHrv: newHrv)
            })
            self.healthStore.execute(query)
        }
        else {
            fatalError("Unable to query Health Store. Health data is not available")
        }
    }
    
    // demo function to assign latestHrv to random value
    public func demo() {
        self.latestHrv = HRItem(value: Double.random(in: 1...60), timestamp: Date())
    }
    
    public func stopPolling() {
        // for now all we do is set latestHrv to nil
        self.latestHrv = nil
    }
    
    private func calculateHrv(hrSamples: [HRItem]) -> HRItem {
        let hrSamplesInMS = hrSamples.map { (sample) -> Double in
            // convert bpm -> ms
            return 60_000 / sample.value
        }
        
        let hrvInMS = self.calculateStdDev(samples: hrSamplesInMS)
        let hrvTimestamp = hrSamples.last!.timestamp
        
        return HRItem(value: hrvInMS, timestamp: hrvTimestamp)
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

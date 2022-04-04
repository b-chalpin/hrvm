//
//  HeartRatePoller.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/7/22.
//

import Foundation
import HealthKit

// TODO: move to config
let HR_WINDOW_SIZE = 15
let HR_STORE_SIZE = 60
let HRV_STORE_SIZE = 15

// it is assumed that when status is .active, hrv will be defined
enum HeartRatePollerStatus {
    case stopped
    case starting
    case active
}

public class HeartRatePoller : ObservableObject {
    // constants
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let healthStore: HKHealthStore = HKHealthStore()
    
    // variable to indicate whether we have notified the poller to stop
    private var hasBeenStopped: Bool = true
    
    // variables
    private var hrvStore: [HRVItem]
    
    // UI will be subscribed to this
    @Published var latestHrv: HRVItem?
    
    // status of poller. stopped on initialization
    @Published var status: HeartRatePollerStatus = .stopped
    
    // auth status
    @Published var authStatus: HKAuthorizationStatus = .notDetermined
    
    public init() {
        self.hrvStore = []
        
        self.requestAuthorization()
    }
    
    public func getHrvStore() -> [HRVItem] {
        return self.hrvStore
    }
    
    private func updateAuthStatus() {
        self.authStatus = healthStore.authorizationStatus(for: self.heartRateQuantityType)
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
    
    public func isActive() -> Bool {
        return self.status == HeartRatePollerStatus.active
    }
    
    public func poll() {
        if (HKHealthStore.isHealthDataAvailable()) {
            let sortByTimeDescending = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: self.heartRateQuantityType, predicate: nil, limit: HR_WINDOW_SIZE, sortDescriptors: [sortByTimeDescending], resultsHandler: { (query, results, error) in
                // there is a chance that we have stopped the polling, check this first before continuing
                if self.hasBeenStopped {
                    print("Heart Rate Poller has been told to stop. Aborting query")
                    return
                }
                
                if let error = error {
                    print("ERROR - Unexpected error occurred - \(error)")
                }
                
                guard let results = results else {
                    print("ERROR - query results are empty")
                    return
                }
                
                if results.count == 0 {
                    print("No records returned for heart rate")
                    return
                }
                
                DispatchQueue.main.async {
                    // list of new samples
                    let newHRSamples = results.map { (sample) -> HRItem in
                        let quantity = (sample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        
                        let heartRateBpm = quantity.doubleValue(for: heartRateUnit)
                        let heartRateTimestamp = sample.endDate
                        
                        return HRItem(value: heartRateBpm, timestamp: heartRateTimestamp)
                    }
                    
                    let newHrv = self.calculateHrv(hrSamples: newHRSamples)

                        // update subscribed views with new hrv and active status
                        self.latestHrv = newHrv
                        self.updateStatus(status: .active)

                        print("HRV UPDATED: \(self.latestHrv!)")

                    
                    // add new Hrv to store
                    self.addHrvToHrvStore(newHrv: newHrv)
                }
            })
            self.healthStore.execute(query)
        }
        else {
            fatalError("Unable to query Health Store. Health data is not available")
        }
    }
    
    // demo function to assign latestHrv to random value
    public func demo() {
        if self.hasBeenStopped {
            print("HRPoller has been stopped. Cancelling random HRV polling")
            return
        }
        
        let randHrvValue = Double.random(in: 1...100)
        
        // create dummy HRVItem
        self.latestHrv = HRVItem(value: randHrvValue,
                                 timestamp: Date(),
                                 deltaHrvValue: 0.0,
                                 deltaUnixTimestamp: 0.0,
                                 avgHeartRateMS: 0.0,
                                 numHeartRateSamples: 0,
                                 hrSamples: [])
        
        self.status = .active
        
        print("Random HRV value: \(self.latestHrv!)")
    }
    
    public func stopPolling() {
        self.hasBeenStopped = true
        self.latestHrv = nil
        self.updateStatus(status: .stopped)
    }
    
    public func resetStoppedFlag() {
        self.hasBeenStopped = false
    }
    
    private func calculateHrv(hrSamples: [HRItem]) -> HRVItem {
        let hrSamplesInMS = hrSamples.map { (sample) -> Double in
            // convert bpm -> ms
            return 60_000 / sample.value
        }
        
        // calculate HRV
        let hrvInMS = self.calculateStdDev(samples: hrSamplesInMS)
        
        // calculate metadata for HRV
        let hrvTimestamp = hrSamples.last!.timestamp
        let avgHeartRateMS = self.calculateMean(samples: hrSamplesInMS)
        let deltaHrvValue = self.calculateDeltaHrvValue(newHrvValue: hrvInMS)
        let deltaUnixTimestamp = self.calculateDeltaUnixTimestamp(newHrvTimestamp: hrvTimestamp)
        let numHeartRateSamples = HR_WINDOW_SIZE
        
        // finally create a new HRV sample
        return HRVItem(value: hrvInMS,
                       timestamp: hrvTimestamp,
                       deltaHrvValue: deltaHrvValue,
                       deltaUnixTimestamp: deltaUnixTimestamp,
                       avgHeartRateMS: avgHeartRateMS,
                       numHeartRateSamples: numHeartRateSamples,
                       hrSamples: hrSamples)
    }
    
    private func calculateStdDev(samples: [Double]) -> Double {
        let length = Double(samples.count)
        let avg = self.calculateMean(samples: samples)
        let sumOfSquaredAvgDiff = samples.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    private func calculateMean(samples: [Double]) -> Double {
        if samples.count == 0 {
            fatalError("Cannot calculate the mean of 0 samples. Will result in a divide by 0")
        }
        
        let length = Double(samples.count)
        return samples.reduce(0, {$0 + $1}) / length
    }
    
    private func calculateDeltaHrvValue(newHrvValue: Double) -> Double {
        if let latestHrvValue = self.latestHrv?.value {
            return newHrvValue - latestHrvValue
        }
        else {
            return 0.0
        }
    }
    
    private func calculateDeltaUnixTimestamp(newHrvTimestamp: Date) -> Double {
        if let latestHrvTiemstamp = self.latestHrv?.timestamp {
            return newHrvTimestamp.timeIntervalSince1970 - latestHrvTiemstamp.timeIntervalSince1970
        }
        else {
            return 0.0
        }
    }
    
    private func addHrvToHrvStore(newHrv: HRVItem) {
        if self.hrvStore.count == HRV_STORE_SIZE {
            self.hrvStore.removeFirst()
        }
        self.hrvStore.append(newHrv)
    }
      
    private func updateStatus(status: HeartRatePollerStatus) {
        self.status = status
    }
}

// ======================================================================
// File: HeartRatePoller.swift
// Author: Nick Adams
// Date: 5/9/2022
// Description: This file contains the implementation of the HeartRatePoller class
// ======================================================================

import Foundation
import HealthKit
import Accelerate
import CoreData

// it is assumed that when status is .active, hrv will be defined
// Enumeration to represent the status of the HeartRatePoller
enum HeartRatePollerStatus {
    case stopped
    case starting
    case active
}

public class HeartRatePoller: ObservableObject {
    // Singleton instance of the HeartRatePoller
    public static let shared: HeartRatePoller = HeartRatePoller()
    
    private var storageService = StorageService.shared
    
    // Flag to indicate whether the poller has been stopped
    private var hasBeenStopped: Bool = true

    // Published properties
    @Published var latestHrv: HrvItem? // Current HRV value
    @Published var hrvStore: [HrvItem] // Array to store HRV values being calculated
    @Published var status: HeartRatePollerStatus // Current status of the poller
    @Published var authStatus: HKAuthorizationStatus = .notDetermined // Authorization status for accessing health data
    
    // HRV statistics for the UI
    @Published var minHrvValue: Double = 0.0
    @Published var maxHrvValue: Double = 0.0
    @Published var avgHrvValue: Double = 0.0
    
    // Constants
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let healthStore: HKHealthStore = HKHealthStore()
    
    // Initializes the HeartRatePoller object
    public init() {
        self.status = .stopped
        self.latestHrv = nil
        self.hrvStore = []
        self.requestAuthorization()
    }
    
    // Returns the HRV store
    public func getHrvStore() -> [HrvItem] {
        return self.hrvStore
    }
    
    // Updates the authorization status for accessing health data
    private func updateAuthStatus() {
        self.authStatus = healthStore.authorizationStatus(for: self.heartRateQuantityType)
    }
    
    // Requests authorization for reading heart rate data
    private func requestAuthorization() {
        let sharing = Set<HKSampleType>()
        let reading = Set<HKObjectType>([self.heartRateQuantityType])
        healthStore.requestAuthorization(toShare: sharing, read: reading) { [weak self] result, error in
            if result {
                DispatchQueue.main.async {
                    self?.updateAuthStatus()
                }
            } else if let error = error {
                print("ERROR - Auth failed: \(error.localizedDescription)")
            } else {
                fatalError("ERROR - Fatal error occurred when requesting Health Store authorization")
            }
        }
    }
    
    // Checks if the poller is active
    public func isActive() -> Bool {
        return self.status == .active
    }
    
    // Polls heart rate data and calculates HRV
    public func poll() {
        if (HKHealthStore.isHealthDataAvailable()) {
            let sortByTimeDescending = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: self.heartRateQuantityType, predicate: nil, limit: Settings.HRWindowSize, sortDescriptors: [sortByTimeDescending], resultsHandler: { (query, results, error) in
                // there is a chance that we have stopped the polling, check this first before continuing
                if self.hasBeenStopped {
                    print("LOG - Heart Rate Poller has been told to stop. Aborting query")
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
                // map health store query result to HRItem array
                let newHRSamples = results.map { (sample) -> HrItem in
                    let quantity = (sample as! HKQuantitySample).quantity
                    let heartRateUnit = HKUnit(from: "count/min")
                    
                    let heartRateBpm = quantity.doubleValue(for: heartRateUnit)
                    let heartRateTimestamp = sample.endDate
                    
                    return HrItem(hr: heartRateBpm, timestamp: heartRateTimestamp)
                }
                
                let newHrv = self.calculateHrv(hrSamples: newHRSamples)

                // update subscribed views with new hrv and active status
                self.latestHrv = newHrv
                self.updateStatus(status: .active)

                print("LOG - HRV UPDATED: RMSSD: \(self.latestHrv!.RMSSD), meanRR: \(self.latestHrv!.meanRR) medianRR: \(self.latestHrv!.medianRR), pNN50: \(self.latestHrv!.pNN50)")
                
                // add new Hrv to store
                self.addHrvToHrvStore(newHrv: newHrv)
                
                // store new HRV to CoreData
                self.storageService.createHrvItem(hrvItem: newHrv)
            }
        })
        self.healthStore.execute(query)
    }
    else {
        fatalError("ERROR - Unable to query Health Store. Health data is not available")
    }
}
    
    // demo function to assign latestHrv to random value
    // - `demo()`: a function to simulate HRV values for demo purposes.
    public func demo() {
        if self.hasBeenStopped {
            print("LOG - HRPoller has been stopped. Cancelling random HRV polling")
            return
        }
        
        let randHrvValue = Double.random(in: 1...100)
        let newHrv = HrvItem(RMSSD: randHrvValue,
                             timestamp: Date(),
                             deltaHrvValue: 0.0,
                             deltaUnixTimestamp: 1.0,
                             avgHeartRateMS: 900.0,
                             numHeartRateSamples: 0,
                             hrSamples: [],
                             meanRR: 0.0,
                             medianRR: 0.0,
                             pNN50: 0.0)
        
        self.latestHrv = newHrv
        
        // for the demo graph
        self.addHrvToHrvStore(newHrv: newHrv)
        
        self.status = .active
        
        print("LOG - Random HRV value: \(self.latestHrv!)")
    }
    
    // - `initPolling()`: a function to initialize the poller.
    public func initPolling() {
        self.resetStoppedFlag()
        self.status = .starting
    }
    
    // - `stopPolling()`: a function to stop the poller.
    public func stopPolling() {
        self.hasBeenStopped = true
        self.latestHrv = nil
        self.resetHrvStats()
        self.updateStatus(status: .stopped)
    }
    
    // - `resetStoppedFlag()`: a function to reset the stopped flag.
    public func resetStoppedFlag() {
        self.hasBeenStopped = false
    }
    
    // - `calculateHrv(hrSamples: [HrItem])`: a function that calculates the HRV value based on an array of heart rate data samples.
    private func calculateHrv(hrSamples: [HrItem]) -> HrvItem {
        let hrSamplesInMS = hrSamples.map { (sample) -> Double in
            // convert bpm -> ms
            return 60_000 / sample.hr
        }
        
        // calculate HRV
        let hrvInMS = self.calculateStdDev(samples: hrSamplesInMS)
        
        // calculate metadata for HRV
        let hrvTimestamp = hrSamples.last!.timestamp
        let avgHeartRateMS = self.calculateMean(samples: hrSamplesInMS)
        let deltaHrvValue = self.calculateDeltaHrvValue(newHrvValue: hrvInMS)
        let deltaUnixTimestamp = self.calculateDeltaUnixTimestamp(newHrvTimestamp: hrvTimestamp)
        let numHeartRateSamples = Settings.HRWindowSize
        let meanRR = self.calculateMeanRR(hrSamples: hrSamples)
        let medianRR = self.calculateMedianRR(hrSamples: hrSamples)
        let pNN50 = self.calculatePNN50(hrSamples: hrSamples)
        
        // finally create a new HRV sample
        return HrvItem(RMSSD: hrvInMS,
                       timestamp: hrvTimestamp,
                       deltaHrvValue: deltaHrvValue,
                       deltaUnixTimestamp: deltaUnixTimestamp,
                       avgHeartRateMS: avgHeartRateMS,
                       numHeartRateSamples: numHeartRateSamples,
                       hrSamples: hrSamples,
                       meanRR: meanRR,
                       medianRR: medianRR,
                       pNN50: pNN50)
    }
    
    // - `calculateStdDev(samples: [Double])`: a function that calculates the standard deviation of an array of samples.
    private func calculateStdDev(samples: [Double]) -> Double {
        let length = Double(samples.count)
        let avg = self.calculateMean(samples: samples)
        let sumOfSquaredAvgDiff = samples.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    // - `calculateMean(samples: [Double])`: a function that calculates the mean of an array of samples.
    private func calculateMean(samples: [Double]) -> Double {
        if samples.count == 0 {
            fatalError("ERROR - Cannot calculate the mean of 0 samples. Will result in a divide by 0")
        }
        
        let length = Double(samples.count)
        return samples.reduce(0, {$0 + $1}) / length
    }
    
    // - `calculateDeltaHrvValue(newHrvValue: Double)`: a function that calculates the change in HRV value from the previous value.
    private func calculateDeltaHrvValue(newHrvValue: Double) -> Double {
        if let latestHrvValue = self.latestHrv?.RMSSD {
            return newHrvValue - latestHrvValue
        }
        else {
            return 0.0
        }
    }
    
    // - `calculateDeltaUnixTimestamp(newHrvTimestamp: Date)`: a function that calculates the change in Unix timestamp from the previous HRV value.
    private func calculateDeltaUnixTimestamp(newHrvTimestamp: Date) -> Double {
        if let latestHrvTiemstamp = self.latestHrv?.timestamp {
            return newHrvTimestamp.timeIntervalSince1970 - latestHrvTiemstamp.timeIntervalSince1970
        }
        else {
            return 0.0
        }
    }

    // - `calculateMeanRR(hrSamples: [HrItem])`: a function that calculates the mean RR interval (inter-beat interval) from an array of heart rate samples.
    private func calculateMeanRR(hrSamples: [HrItem]) -> Double {
        let rrIntervals = hrSamples.map { (sample) -> Double in
            return 60.0 / sample.hr * 1000.0 // convert BPM to RR interval in milliseconds
        }
        
        return self.calculateMean(samples: rrIntervals)
    }

    // - `calculateMedianRR(hrSamples: [HrItem])`: a function that calculates the median RR interval (inter-beat interval) from an array of heart rate samples. 
    private func calculateMedianRR(hrSamples: [HrItem]) -> Double {
        let rrIntervals = hrSamples.map { (sample) -> Double in
            return 60.0 / sample.hr * 1000.0 // convert BPM to RR interval in milliseconds
        }
        
        let sortedRRIntervals = rrIntervals.sorted()
        let length = sortedRRIntervals.count
        
        if length % 2 == 0 {
            // even number of samples
            let midIndex = length / 2
            let median = (sortedRRIntervals[midIndex] + sortedRRIntervals[midIndex - 1]) / 2.0
            return median
        }
        else {
            // odd number of samples
            let midIndex = length / 2
            return sortedRRIntervals[midIndex]
        }
    }

    // - `calculatepNN50(hrSamples: [HrItem])`: a function that calculates the percentage of NN50 values from an array of heart rate samples.
    private func calculatePNN50(hrSamples: [HrItem]) -> Double {
        let rrIntervals = hrSamples.map { (sample) -> Double in
            return 60.0 / sample.hr * 1000.0 // convert BPM to RR interval in milliseconds
        }

        let length = rrIntervals.count
        var pNN50 = 0.0
        
        for i in 0..<length - 1 {
            let diff = abs(rrIntervals[i] - rrIntervals[i + 1])
            if diff > 50.0 {
                pNN50 += 1.0
            }
        }
        
        return (pNN50 / Double(length)) * 100.0
    }

    // - `addHrvToHrvStore(newHrv: HrvItem)`: a function that adds the latest HRV value to the `hrvStore`.
    private func addHrvToHrvStore(newHrv: HrvItem) {
        if self.hrvStore.count == Settings.HRVStoreSize {
            self.hrvStore.removeFirst()
        }
        self.hrvStore.append(newHrv)
        
        self.updateHrvStats()
    }
    
    // - `updateHrvStats()`: a function that updates the statistics for the HRV values stored in `hrvStore`.
    private func updateHrvStats() {
        if self.hrvStore.count == 0 {
            self.resetHrvStats()
        }
        else {
            let hrvStoreValues = self.hrvStore.map { $0.RMSSD }
            
            self.minHrvValue = hrvStoreValues.min()!
            self.maxHrvValue = hrvStoreValues.max()!
            self.avgHrvValue = self.calculateMean(samples: hrvStoreValues)
        }
    }
    
    // - `resetHrvStats()`: a function that resets the HRV statistics to their default values.
    private func resetHrvStats() {
        self.minHrvValue = 0.0
        self.maxHrvValue = 0.0
        self.avgHrvValue = 0.0
    }
      
    // - `updateStatus(status: HeartRatePollerStatus)`: a function that updates the status of the poller.
    private func updateStatus(status: HeartRatePollerStatus) {
        self.status = status
    }
}

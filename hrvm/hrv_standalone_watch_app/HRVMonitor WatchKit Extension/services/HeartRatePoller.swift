// This is a Swift file for a Heart Rate Variability (HRV) Poller class in an Apple Watch application.
// It imports the HealthKit framework to access the user's heart rate data. 

// The `HeartRatePoller` class is an ObservableObject and contains several properties, including:
// - `latestHrv`: the current HRV value.
// - `hrvStore`: an array to store HRV values that are being calculated.
// - `status`: an enum that represents the current status of the poller (stopped, starting, or active).
// - `authStatus`: the authorization status for accessing the user's heart rate data.
// - `minHrvValue`, `maxHrvValue`, and `avgHrvValue`: statistics for the HRV values that are being stored.

// The `HeartRatePoller` class also has several functions, including:
// - `poll()`: a function that queries the user's heart rate data and calculates the current HRV.
// - `demo()`: a function to simulate HRV values for demo purposes.
// - `initPolling()`: a function to initialize the poller.
// - `stopPolling()`: a function to stop the poller.
// - `resetStoppedFlag()`: a function to reset the stopped flag.
// - `calculateHrv(hrSamples: [HrItem])`: a function that calculates the HRV value based on an array of heart rate data samples.
// - `calculateStdDev(samples: [Double])`: a function that calculates the standard deviation of an array of samples.
// - `calculateMean(samples: [Double])`: a function that calculates the mean of an array of samples.
// - `calculateDeltaHrvValue(newHrvValue: Double)`: a function that calculates the change in HRV value from the previous value.
// - `calculateMeanRR(hrSamples: [HrItem])`: a function that calculates the mean RR interval (inter-beat interval) from an array of heart rate samples.
// - `calculateMedianRR(hrSamples: [HrItem])`: a function that calculates the median RR interval (inter-beat interval) from an array of heart rate samples.
// - `calculateDeltaUnixTimestamp(newHrvTimestamp: Date)`: a function that calculates the change in Unix timestamp from the previous HRV value.
// - `addHrvToHrvStore(newHrv: HrvItem)`: a function that adds the latest HRV value to the `hrvStore`.
// - `updateHrvStats()`: a function that updates the statistics for the HRV values stored in `hrvStore`.
// - `resetHrvStats()`: a function that resets the HRV statistics to their default values.
// - `updateStatus(status: HeartRatePollerStatus)`: a function that updates the status of the poller.

import Foundation
import HealthKit

// it is assumed that when status is .active, hrv will be defined
enum HeartRatePollerStatus {
    case stopped
    case starting
    case active
}

public class HeartRatePoller : ObservableObject {
    // singleton
    public static let shared: HeartRatePoller = HeartRatePoller()
    
    private var storageService = StorageService.shared
    
    // variable to indicate whether we have notified the poller to stop
    private var hasBeenStopped: Bool = true

    @Published var latestHrv: HrvItem? // our current HRV
    @Published var hrvStore: [HrvItem] // store our hrv values that are being calculated
    @Published var status: HeartRatePollerStatus
    @Published var authStatus: HKAuthorizationStatus = .notDetermined
    
    // HRV stats for the UI
    @Published var minHrvValue: Double = 0.0
    @Published var maxHrvValue: Double = 0.0
    @Published var avgHrvValue: Double = 0.0
    
    // constants
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let healthStore: HKHealthStore = HKHealthStore()
    
    public init() {        
        self.status = .stopped
        self.latestHrv = nil
        self.hrvStore = []
        self.requestAuthorization()
    }
    
    public func getHrvStore() -> [HrvItem] {
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
                print("ERROR - Auth failed: \(error.localizedDescription)")
            } else {
                fatalError("ERROR - Fatal error occurred when requesting Health Store authorization")
            }
        }
    }
    
    public func isActive() -> Bool {
        return self.status == .active
    }
    
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
                    
                    return HrItem(value: heartRateBpm, timestamp: heartRateTimestamp)
                }
                
                let newHrv = self.calculateHrv(hrSamples: newHRSamples)

                // update subscribed views with new hrv and active status
                self.latestHrv = newHrv
                self.updateStatus(status: .active)

                print("LOG - HRV UPDATED: RMSSD: \(self.latestHrv!.value), meanRR: \(self.latestHrv!.meanRR) medianRR: \(self.latestHrv!.medianRR)")
                
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
    public func demo() {
        if self.hasBeenStopped {
            print("LOG - HRPoller has been stopped. Cancelling random HRV polling")
            return
        }
        
        let randHrvValue = Double.random(in: 1...100)
        let newHrv = HrvItem(value: randHrvValue,
                             timestamp: Date(),
                             deltaHrvValue: 0.0,
                             deltaUnixTimestamp: 1.0,
                             avgHeartRateMS: 900.0,
                             numHeartRateSamples: 0,
                             hrSamples: [],
                             meanRR: 0.0,
                             medianRR: 0.0)
        
        self.latestHrv = newHrv
        
        // for the demo graph
        self.addHrvToHrvStore(newHrv: newHrv)
        
        self.status = .active
        
        print("LOG - Random HRV value: \(self.latestHrv!)")
    }
    
    public func initPolling() {
        self.resetStoppedFlag()
        self.status = .starting
    }
    
    public func stopPolling() {
        self.hasBeenStopped = true
        self.latestHrv = nil
        self.resetHrvStats()
        self.updateStatus(status: .stopped)
    }
    
    public func resetStoppedFlag() {
        self.hasBeenStopped = false
    }
    
    private func calculateHrv(hrSamples: [HrItem]) -> HrvItem {
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
        let numHeartRateSamples = Settings.HRWindowSize
        let meanRR = self.calculateMeanRR(hrSamples: hrSamples)
        let medianRR = self.calculateMedianRR(hrSamples: hrSamples)
        
        // finally create a new HRV sample
        return HrvItem(value: hrvInMS,
                       timestamp: hrvTimestamp,
                       deltaHrvValue: deltaHrvValue,
                       deltaUnixTimestamp: deltaUnixTimestamp,
                       avgHeartRateMS: avgHeartRateMS,
                       numHeartRateSamples: numHeartRateSamples,
                       hrSamples: hrSamples,
                       meanRR: meanRR,
                       medianRR: medianRR)
    }
    
    private func calculateStdDev(samples: [Double]) -> Double {
        let length = Double(samples.count)
        let avg = self.calculateMean(samples: samples)
        let sumOfSquaredAvgDiff = samples.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    private func calculateMean(samples: [Double]) -> Double {
        if samples.count == 0 {
            fatalError("ERROR - Cannot calculate the mean of 0 samples. Will result in a divide by 0")
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

    private func calculateMeanRR(hrSamples: [HrItem]) -> Double {
        let rrIntervals = hrSamples.map { (sample) -> Double in
            return 60.0 / sample.value * 1000.0 // convert BPM to RR interval in milliseconds
        }
        
        return self.calculateMean(samples: rrIntervals)
    }

    private func calculateMedianRR(hrSamples: [HrItem]) -> Double {
        let rrIntervals = hrSamples.map { (sample) -> Double in
            return 60.0 / sample.value * 1000.0 // convert BPM to RR interval in milliseconds
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


    
    private func addHrvToHrvStore(newHrv: HrvItem) {
        if self.hrvStore.count == Settings.HRVStoreSize {
            self.hrvStore.removeFirst()
        }
        self.hrvStore.append(newHrv)
        
        self.updateHrvStats()
    }
    
    private func updateHrvStats() {
        if self.hrvStore.count == 0 {
            self.resetHrvStats()
        }
        else {
            let hrvStoreValues = self.hrvStore.map { $0.value }
            
            self.minHrvValue = hrvStoreValues.min()!
            self.maxHrvValue = hrvStoreValues.max()!
            self.avgHrvValue = self.calculateMean(samples: hrvStoreValues)
        }
    }
    
    private func resetHrvStats() {
        self.minHrvValue = 0.0
        self.maxHrvValue = 0.0
        self.avgHrvValue = 0.0
    }
      
    private func updateStatus(status: HeartRatePollerStatus) {
        self.status = status
    }
}

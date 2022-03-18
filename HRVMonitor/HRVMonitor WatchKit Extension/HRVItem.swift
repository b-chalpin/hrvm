//
//  HRVItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/17/22.
//

import Foundation

// class reposible for storing a single HRV sample's data
public class HRVItem : MonitorItem<Double> {
    public var deltaHrvValue: Double // difference in HRV from the previous HRVItem
    public var deltaUnixTimestamp: Double // difference in time since the previous HRVItem
    public var avgHeartRateBPM: Double // average heart rate for the samples used to calculate this HRV in BPM
    public var avgHeartRateMS: Double // average heart rate for the samples used to calculate this HRV in Milliseconds
    public var numHeartRateSamples: Int // number of heart rate samples used to calculate this HRV
    public var hrSamples: [HRItem] // store the HR samples used to calculate HRV
    
    init(value: Double, timestamp: Date, deltaHrvValue: Double, deltaUnixTimestamp: Double, avgHeartRateMS: Double, numHeartRateSamples: Int, hrSamples: [HRItem]) {
        self.deltaHrvValue = deltaHrvValue
        self.deltaUnixTimestamp = deltaUnixTimestamp
        self.avgHeartRateBPM = 60_000 / avgHeartRateMS
        self.avgHeartRateMS = avgHeartRateMS
        self.numHeartRateSamples = numHeartRateSamples
        self.hrSamples = hrSamples
        
        super.init(value: value, timestamp: timestamp)
    }
    
    public override var description: String {
        "Value: \(self.value) - Timestamp: \(self.timestamp) - deltaHrvValue: \(self.deltaHrvValue) - deltaUnixTimestamp: \(self.deltaUnixTimestamp) - avgHeartRateBPM: \(self.avgHeartRateBPM) - avgHeartRateMS: \(self.avgHeartRateMS) - numHRSamples: \(self.numHeartRateSamples)"
    }
}

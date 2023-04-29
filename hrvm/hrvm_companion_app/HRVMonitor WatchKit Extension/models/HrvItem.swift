//
//  HRVItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the HrvItem class for the HRVMonitor WatchKit Extension.
//  The HrvItem class is responsible for storing data related to a single HRV sample,
//  including its value, timestamp, Unix timestamp, delta HRV value, delta Unix timestamp,
//  average heart rate in BPM and milliseconds, the number of heart rate samples used
//  to calculate the HRV, and the HR samples themselves. This class is used to represent
//  individual HRV samples within the app and facilitate the organization and processing
//  of HRV data.
//
//  Created by bchalpin on 3/17/22.
//

import Foundation

// class reposible for storing a single HRV sample's data
public class HrvItem : NSObject, Codable {
    public var RMSSD: Double
    public var timestamp: Date
    
    public var unixTimestamp: Double
    public var deltaHrvValue: Double // difference in HRV from the previous HRVItem
    public var deltaUnixTimestamp: Double // difference in time since the previous HRVItem
    public var avgHeartRateBPM: Double // average heart rate for the samples used to calculate this HRV in BPM
    public var avgHeartRateMS: Double // average heart rate for the samples used to calculate this HRV in Milliseconds
    public var numHeartRateSamples: Int // number of heart rate samples used to calculate this HRV
    public var hrSamples: [HrItem] // store the HR samples used to calculate HRV
    public var meanRR: Double // mean of RR intervals (inter-beat intervals) in milliseconds
    public var medianRR: Double = 0.0 // median of RR intervals (inter-beat intervals) in milliseconds
    public var pNN50: Double = 0.0 // percentage of NN50 values
    
    init(RMSSD: Double, timestamp: Date, deltaHrvValue: Double, deltaUnixTimestamp: Double, avgHeartRateMS: Double, numHeartRateSamples: Int, hrSamples: [HrItem], meanRR: Double, medianRR: Double, pNN50: Double) {
        self.RMSSD = RMSSD
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
        self.deltaHrvValue = deltaHrvValue
        self.deltaUnixTimestamp = deltaUnixTimestamp
        self.avgHeartRateBPM = 60_000 / avgHeartRateMS
        self.avgHeartRateMS = avgHeartRateMS
        self.numHeartRateSamples = numHeartRateSamples
        self.hrSamples = hrSamples
        self.meanRR = meanRR
        self.medianRR = medianRR
        self.pNN50 = pNN50
    }
    
    public override var description: String {
//        "RMSSD: \(self.RMSSD) - Timestamp: \(self.timestamp) - deltaHrvValue: \(self.deltaHrvValue) - deltaUnixTimestamp: \(self.deltaUnixTimestamp) - avgHeartRateBPM: \(self.avgHeartRateBPM) - avgHeartRateMS: \(self.avgHeartRateMS) - numHRSamples: \(self.numHeartRateSamples) - meanRR: \(self.meanRR) - medianRR: \(self.medianRR) - pNN50: \(self.pNN50)"
        "\(self.RMSSD)"
    }
}

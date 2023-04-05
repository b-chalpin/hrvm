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

// Helper function to calculate the mean RR interval
func calculateMeanRR(hrSamples: [HrItem]) -> Double {
    let totalRRIntervals = hrSamples.count - 1
    if totalRRIntervals <= 0 { return 0.0 }

    var sumRRIntervals = 0.0
    for i in 1..<hrSamples.count {
        let rrInterval = hrSamples[i].unixTimestamp - hrSamples[i - 1].unixTimestamp
        sumRRIntervals += rrInterval * 1000 // Convert to milliseconds
    }

    return sumRRIntervals / Double(totalRRIntervals)
}

// class reposible for storing a single HRV sample's data
public class HrvItem : NSObject, Codable {
    public var value: Double
    public var timestamp: Date
    
    public var unixTimestamp: Double
    public var deltaHrvValue: Double // difference in HRV from the previous HRVItem
    public var deltaUnixTimestamp: Double // difference in time since the previous HRVItem
    public var avgHeartRateBPM: Double // average heart rate for the samples used to calculate this HRV in BPM
    public var avgHeartRateMS: Double // average heart rate for the samples used to calculate this HRV in Milliseconds
    public var numHeartRateSamples: Int // number of heart rate samples used to calculate this HRV
    public var hrSamples: [HrItem] // store the HR samples used to calculate HRV
    public var meanRR: Double // mean of RR intervals (inter-beat intervals) in milliseconds
    
    init(value: Double, timestamp: Date, deltaHrvValue: Double, deltaUnixTimestamp: Double, avgHeartRateMS: Double, numHeartRateSamples: Int, hrSamples: [HrItem]) {
        self.value = value
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
        self.deltaHrvValue = deltaHrvValue
        self.deltaUnixTimestamp = deltaUnixTimestamp
        self.avgHeartRateBPM = 60_000 / avgHeartRateMS
        self.avgHeartRateMS = avgHeartRateMS
        self.numHeartRateSamples = numHeartRateSamples
        self.hrSamples = hrSamples
        self.meanRR = calculateMeanRR(hrSamples: hrSamples)
    }
    
    public override var description: String {
//        "Value: \(self.value) - Timestamp: \(self.timestamp) - deltaHrvValue: \(self.deltaHrvValue) - deltaUnixTimestamp: \(self.deltaUnixTimestamp) - avgHeartRateBPM: \(self.avgHeartRateBPM) - avgHeartRateMS: \(self.avgHeartRateMS) - numHRSamples: \(self.numHeartRateSamples)"
        "\(self.value)"
    }
}


//
//  HRVItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the `HrvItem` class for the HRVMonitor WatchKit Extension.
//  The `HrvItem` class is responsible for storing data related to a single HRV sample,
//  including its value, timestamp, Unix timestamp, delta HRV value, delta Unix timestamp,
//  average heart rate in BPM and milliseconds, the number of heart rate samples used
//  to calculate the HRV, and the HR samples themselves. This class is used to represent
//  individual HRV samples within the app and facilitate the organization and processing
//  of HRV data.
//
//  Created by bchalpin on 3/17/22.
//

import Foundation

/// The class responsible for storing data related to a single HRV sample.
public class HrvItem: NSObject, Codable {
    /// The Root Mean Square of Successive Differences (RMSSD) value of the HRV sample.
    public var RMSSD: Double
    /// The timestamp of when the HRV sample was recorded.
    public var timestamp: Date
    /// The Unix timestamp (in seconds) of when the HRV sample was recorded.
    public var unixTimestamp: Double
    /// The difference in HRV from the previous HRV sample.
    public var deltaHrvValue: Double
    /// The difference in time since the previous HRV sample.
    public var deltaUnixTimestamp: Double
    /// The average heart rate for the samples used to calculate this HRV in BPM.
    public var avgHeartRateBPM: Double
    /// The average heart rate for the samples used to calculate this HRV in milliseconds.
    public var avgHeartRateMS: Double
    /// The number of heart rate samples used to calculate this HRV.
    public var numHeartRateSamples: Int
    /// The HR samples used to calculate HRV.
    public var hrSamples: [HrItem]
    /// The mean of RR intervals (inter-beat intervals) in milliseconds.
    public var meanRR: Double
    /// The median of RR intervals (inter-beat intervals) in milliseconds.
    public var medianRR: Double = 0.0
    /// The percentage of NN50 values.
    public var pNN50: Double = 0.0
    
    /// Initializes a new instance of the `HrvItem` class.
    ///
    /// - Parameters:
    ///   - RMSSD: The RMSSD value of the HRV sample.
    ///   - timestamp: The timestamp of when the HRV sample was recorded.
    ///   - deltaHrvValue: The difference in HRV from the previous HRV sample.
    ///   - deltaUnixTimestamp: The difference in time since the previous HRV sample.
    ///   - avgHeartRateMS: The average heart rate for the samples used to calculate this HRV in milliseconds.
    ///   - numHeartRateSamples: The number of heart rate samples used to calculate this HRV.
    ///   - hrSamples: The HR samples used to calculate HRV.
    ///   - meanRR: The mean of RR intervals (inter-beat intervals) in milliseconds.
    ///   - medianRR: The median of RR intervals (inter-beat intervals) in milliseconds.
    ///   - pNN50: The percentage of NN50 values.
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
        "\(self.RMSSD)"
    }
}

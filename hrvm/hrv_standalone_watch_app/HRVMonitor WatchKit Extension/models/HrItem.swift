//
//  HrItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the `HrItem` class for the HRVMonitor WatchKit Extension.
//  The `HrItem` class is responsible for storing data related to a single heart rate sample,
//  including its value, timestamp, and Unix timestamp. This class is used to represent
//  individual heart rate samples within the app and facilitate the organization and processing
//  of heart rate data.
//
//  Created by bchalpin on 3/17/22.
//

import Foundation

/// The class responsible for storing data related to a single heart rate sample.
public class HrItem: NSObject, Codable {
    /// The heart rate value of the sample.
    public var hr: Double
    /// The timestamp of when the heart rate sample was recorded.
    public var timestamp: Date
    /// The Unix timestamp (in seconds) of when the heart rate sample was recorded.
    public var unixTimestamp: Double
    
    /// Initializes a new instance of the `HrItem` class.
    ///
    /// - Parameters:
    ///   - hr: The heart rate value of the sample.
    ///   - timestamp: The timestamp of when the heart rate sample was recorded.
    init(hr: Double, timestamp: Date) {
        self.hr = hr
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}

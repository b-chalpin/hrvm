//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/11/22.
//

import Foundation

/// The base class used for heart rate and HRV data storage.
public class MonitorItem<T>: NSObject {
    /// The value of the monitor item.
    public var value: T
    /// The timestamp of when the monitor item was recorded.
    public var timestamp: Date
    /// The Unix timestamp (in seconds) of when the monitor item was recorded.
    public var unixTimestamp: Double
    
    /// Initializes a new instance of the `MonitorItem` class.
    ///
    /// - Parameters:
    ///   - value: The value of the monitor item.
    ///   - timestamp: The timestamp of when the monitor item was recorded.
    init(value: T, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}

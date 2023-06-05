//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/11/22.
//

import Foundation

// base class used for heart rate and HRV data storage
public class MonitorItem<T> : NSObject {
    public var value: T
    public var timestamp: Date
    public var unixTimestamp: Double
    
    init(value: T, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}

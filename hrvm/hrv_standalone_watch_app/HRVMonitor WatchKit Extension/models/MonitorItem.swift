//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/11/22.
//

import Foundation

// base class used for heart rate and HRV data storage
public class MonitorItem<T> : NSObject {
    public var hr: Int?
    public var RMSSD: Double?
    public var timestamp: Date
    public var unixTimestamp: Double
    
    init(hr: Int? = nil, RMSSD: Double? = nil, timestamp: Date) {
        self.hr = hr
        self.RMSSD = RMSSD
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}

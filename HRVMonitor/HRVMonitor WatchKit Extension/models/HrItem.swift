//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/17/22.
//

import Foundation

// class reposible for storing a single heart rate sample's data
public class HrItem : NSObject, Codable {
    enum Keys: String {
        case value = "value"
        case timestamp = "timestamp"
        case unixTimestamp = "unixTimestamp"
    }
    
    public var value: Double
    public var timestamp: Date
    public var unixTimestamp: Double
    
    init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}

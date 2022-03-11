//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/11/22.
//

import Foundation

public class HRItem {
    public var value: Double
    public var timestamp: Date
    
    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}

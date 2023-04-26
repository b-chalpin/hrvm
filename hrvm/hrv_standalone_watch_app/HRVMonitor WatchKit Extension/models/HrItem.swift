//
//  HRItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the HrItem class for the HRVMonitor WatchKit Extension.
//  The HrItem class is responsible for storing data related to a single heart rate sample,
//  including its value, timestamp, and Unix timestamp. This class is used to represent
//  individual heart rate samples within the app and facilitate the organization and processing
//  of heart rate data.
//
//  Created by bchalpin on 3/17/22.
//


import Foundation

// class reposible for storing a single heart rate sample's data
public class HrItem : NSObject, Codable {
    enum Keys: String {
        case hr = "hr"
        case timestamp = "timestamp"
        case unixTimestamp = "unixTimestamp"
    }
    
    public var hr: Double
    public var timestamp: Date
    public var unixTimestamp: Double
    
    init(hr: Double, timestamp: Date) {
        self.hr = hr
        self.timestamp = timestamp
        self.unixTimestamp = timestamp.timeIntervalSince1970
    }
}
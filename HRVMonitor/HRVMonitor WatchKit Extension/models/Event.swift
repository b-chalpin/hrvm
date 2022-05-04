//
//  Event.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import Foundation

// #task - change this to reflect data types of HRV
struct Event: Identifiable {
    var id: Double
    var timeStamp: String
    var hrv: Double
    var averageHR: Double
    var feedback: String
    var data: [Double]
}

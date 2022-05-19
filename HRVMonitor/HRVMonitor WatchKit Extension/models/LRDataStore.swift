//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 5/18/22.
//

import Foundation

public struct LRDataStore {
    var samples: [[HrvItem]]
    var labels: [Double]
    var size: Int = 0
}

//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 5/18/22.
//

import Foundation

public class LRDataStore : Codable {
    var samples: [[HrvItem]]?
    var labels: [Double]?
    var size: Int = 0
    
    public func add(samples: [[HrvItem]], labels: [Double]) {
        if(self.samples == nil) {
            self.samples = samples
            self.labels = labels
            self.size = samples.count
        }
        else {
            for (sample, label) in zip(samples, labels) {
                self.samples?.append(sample)
                self.labels?.append(label)
            }
            self.size += samples.count
        }
    }
}

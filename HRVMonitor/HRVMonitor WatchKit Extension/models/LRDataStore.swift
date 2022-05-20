//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 5/18/22.
//

import Foundation

public class LRDataStore {
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
            var i = 0
            for sample in samples {
                self.samples?.append(sample)
                self.labels?.append(labels[i])
                i += 1
            }
            self.size += samples.count
        }
    }
}

//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/18/22.
//

import Foundation

public class LRDataStore : Codable {
    var samples: [[HrvItem]]?
    var labels: [Double]?
    var error: [Double]? // array of error values for each fit
    var size: Int = 0 // number of samples
    var stressCount: Int = 0 // count of the number of samples with label == 1
    
    public func add(samples: [[HrvItem]], labels: [Double], feedback: Bool) {
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
        
        if (feedback) {
            self.stressCount += 1
        }
    }
    
    public func addError(error: Double)
    {
        if(self.error == nil) {
            self.error = [error]
        }
        else {
            self.error?.append(error)
        }
    }
}

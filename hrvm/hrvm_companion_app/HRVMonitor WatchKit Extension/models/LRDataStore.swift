//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/18/22.
//

import Foundation

public struct LRDataItem: Codable {
    var sample: [HrvItem]
    var label: Double
    var error: Double?
}

public class LRDataStore : Codable {
    var dataItems: [LRDataItem] = []
    var size: Int = 0 // number of samples
    var stressCount: Int = 0 // count of the number of samples with label == 1
    
    // Creating a new LRDataStore object
    public func add(samples: [[HrvItem]], labels: [Double], errors: [Double]?, feedback: Bool) {
        for (sample, label) in zip(samples, labels) {
            let errorValue = errors == nil ? nil : errors?[size]
            let dataItem = LRDataItem(sample: sample, label: label, error: errorValue)
            dataItems.append(dataItem)
            size += 1
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

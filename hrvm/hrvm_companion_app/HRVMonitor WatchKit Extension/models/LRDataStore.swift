//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/18/22.
//

import Foundation

public struct LRDataItem: Codable {
    var sample: [HrvItem]
    var isStressed: Double
    var sitStandChange: Bool = false
    var error: Double?
}

public class LRDataStore : Codable {
    var dataItems: [LRDataItem] = []
    var size: Int = 0 // number of samples
    var stressCount: Int = 0 // count of the number of samples with label == 1
    
    // Creating a new LRDataStore object
    public func add(samples: [[HrvItem]], isStressed: [Double],  sitStandChange: Bool, errors: [Double]?, feedback: Bool) {
        var errorIndex = 0
        
        for (sample, isStressed) in zip(samples, isStressed) {
            let errorValue = errors == nil ? nil : errors?[errorIndex]
            let dataItem = LRDataItem(sample: sample, isStressed: isStressed, sitStandChange: sitStandChange, error: errorValue)
            dataItems.append(dataItem)
            size += 1
            
            if let _ = errorValue {
                errorIndex += 1
            }
        }
        
        if (feedback) {
            self.stressCount += 1
        }
    }
    
    public func addError(error: Double, atIndex index: Int) {
        guard index >= 0 && index < dataItems.count else {
            print("Error: Invalid index.")
            return
        }
        
        dataItems[index].error = error
    }
}

//
//  LRDataStore.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/18/22.
//

import Foundation

/// A data item containing HRV samples and stress information.
public struct LRDataItem: Codable {
    var sample: [HrvItem]
    var isStressed: Double
    var error: Double?
}

/// A data store for LRDataItems.
public class LRDataStore : Codable {
    var dataItems: [LRDataItem] = []
    var size: Int = 0 // number of samples
    var stressCount: Int = 0 // count of the number of samples with label == 1
    
    /**
     Adds LRDataItems to the data store.
     
     - Parameters:
       - samples: An array of HRV samples.
       - labels: An array of stress labels.
       - errors: An optional array of error values.
       - feedback: A flag indicating whether to provide feedback.
     */
    public func add(samples: [[HrvItem]], labels: [Double], errors: [Double]?, feedback: Bool) {
        var errorIndex = 0
        
        for (sample, isStressed) in zip(samples, labels) {
            let errorValue = errors == nil ? nil : errors?[errorIndex]
            let dataItem = LRDataItem(sample: sample, isStressed: isStressed, error: errorValue)
            dataItems.append(dataItem)
            size += 1
            
            if let _ = errorValue {
                errorIndex += 1
            }
        }
        
        if feedback {
            stressCount += 1
        }
    }
    
    /**
     Adds an error value to a specific LRDataItem.
     
     - Parameters:
       - error: The error value to add.
       - index: The index of the LRDataItem.
     */
    public func addError(error: Double, atIndex index: Int) {
        guard index >= 0 && index < dataItems.count else {
            print("Error: Invalid index.")
            return
        }
        
        dataItems[index].error = error
    }
}

//
//  HrvMapUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/18/22.
//

import Foundation

public class HrvMapUtils {
    public static func mapHrvStoreToDoubleArray(hrvStore: [HrvItem]) -> [Double] {
        return hrvStore.map { hrv in
            return hrv.value
        }
    }
    
    // used ONLY for UI graphs
    public static func mapHrvStoreToDoubleArray_Normalized(hrvStore: [HrvItem]) -> [Double] {
        let hrvStoreDoubles = mapHrvStoreToDoubleArray(hrvStore: hrvStore)
        
        if (hrvStoreDoubles.count < 2) {
            print("mapHrvStoreToDoubleArray_Normalized - Less than 2 HRV Store values found when mapping [HrvItem] -> [Double]. Returning [0.0, 0.0]")
            return [0.0, 0.0]
        }
        
        let min = 0.0 // lowest HRV we can have is 0.0, subtract 10.0 more for padding
        let max = hrvStoreDoubles.max()! + 10.0 // pad our upper bound for normalization

        return hrvStoreDoubles.map { ($0 - min) / (max - min) }
    }
}

//
//  HrvMapUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/18/22.
//
//  This utility class provides methods for mapping HRV data stored in an array of
//  HrvItem objects into an array of Double values.
//
//  Functions:
//  1. mapHrvStoreToDoubleArray(hrvStore: [HrvItem]) -> [Double]: Maps an array of HrvItem
//     objects to an array of Double values by extracting the `value` property of each HrvItem object.
//
//  2. mapHrvStoreToDoubleArray_Normalized(hrvStore: [HrvItem]) -> [Double]: Maps an array
//     of HrvItem objects to an array of normalized Double values, used only for UI graphs.
//     Computes the minimum and maximum values (with some padding) and normalizes the HRV values accordingly.
//


import Foundation

public class HrvMapUtils {
    public static func mapHrvStoreToDoubleArray(hrvStore: [HrvItem]) -> [[String: Double]] {
        return hrvStore.map { hrv in
            return [
                "RMSSD": hrv.value,
                "meanRR": hrv.meanRR,
                "medianRR": hrv.medianRR,
            ]
        }
    }
    
    public static func mapHrvStoreToDoubleArray_Normalized(hrvStore: [HrvItem]) -> [Double] {
        let hrvStoreDicts = mapHrvStoreToDoubleArray(hrvStore: hrvStore)
        let hrvStoreDoubles = hrvStoreDicts.map { $0["RMSSD"]! }

        if (hrvStoreDoubles.count < 2) {
            print("mapHrvStoreToDoubleArray_Normalized - Less than 2 HRV Store values found when mapping [HrvItem] -> [Double]. Returning [0.0, 0.0]")
            return [0.0, 0.0]
        }
        
        let min = 0.0 // lowest HRV we can have is 0.0, subtract 10.0 more for padding
        let max = hrvStoreDoubles.max()! + 10.0 // pad our upper bound for normalization

        return hrvStoreDoubles.map { ($0 - min) / (max - min) }
    }
}

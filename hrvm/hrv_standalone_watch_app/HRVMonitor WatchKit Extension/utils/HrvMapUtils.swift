//
//  HrvMapUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/18/22.
//
//  This utility class provides methods for mapping HRV data stored in an array of
//  HrvItem objects into an array of Double values.
//

import Foundation

public class HrvMapUtils {
    
    // MARK: - Mapping Methods
    
    /// Maps an array of HrvItem objects to an array of dictionaries containing specific HRV values.
    ///
    /// - Parameter hrvStore: The array of HrvItem objects to be mapped.
    /// - Returns: An array of dictionaries where each dictionary represents an HrvItem object with specific HRV values.
    public static func mapHrvStoreToDoubleArray(hrvStore: [HrvItem]) -> [[String: Double]] {
        return hrvStore.map { hrv in
            return [
                "RMSSD": hrv.RMSSD,
                "meanRR": hrv.meanRR,
                "medianRR": hrv.medianRR,
                "pNN50": hrv.pNN50,
            ]
        }
    }
    
    /// Maps an array of HrvItem objects to an array of normalized Double values, used for UI graphs.
    ///
    /// - Parameter hrvStore: The array of HrvItem objects to be mapped.
    /// - Returns: An array of normalized Double values representing the HRV data from the HrvItem objects.
    public static func mapHrvStoreToDoubleArray_Normalized(hrvStore: [HrvItem]) -> [Double] {
        let hrvStoreDicts = mapHrvStoreToDoubleArray(hrvStore: hrvStore)
        let hrvStoreDoubles = hrvStoreDicts.map { $0["RMSSD"]! }

        if hrvStoreDoubles.count < 2 {
            print("mapHrvStoreToDoubleArray_Normalized - Less than 2 HRV Store values found when mapping [HrvItem] -> [Double]. Returning [0.0, 0.0]")
            return [0.0, 0.0]
        }
        
        let min = 0.0 // The lowest HRV value is 0.0, subtract 10.0 more for padding
        let max = hrvStoreDoubles.max()! + 10.0 // Pad the upper bound for normalization

        return hrvStoreDoubles.map { ($0 - min) / (max - min) }
    }
}

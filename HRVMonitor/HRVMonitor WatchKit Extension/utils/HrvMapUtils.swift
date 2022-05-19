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
}

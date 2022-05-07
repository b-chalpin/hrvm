//
//  StringFormatUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/6/22.
//

import Foundation

class StringFormatUtils {
    public static func formatDoubleToString(input: Double) -> String {
        return String(format: "%.1f", input)
    }
}

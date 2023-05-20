//
//  StringFormatUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/6/22.
//

import Foundation

class StringFormatUtils {
    
    // MARK: - Formatting Methods
    
    /// Formats a double value to a string with one decimal place.
    ///
    /// - Parameter input: The double value to be formatted.
    /// - Returns: A string representation of the input double with one decimal place.
    public static func formatDoubleToString(input: Double) -> String {
        return String(format: "%.1f", input)
    }
    
    /// Formats a date value to a string representation.
    ///
    /// - Parameter input: The date value to be formatted.
    /// - Returns: A string representation of the input date using the format "M/d/y, HH:mm:ss".
    public static func formatDateToString(input: Date) -> String {
        let dateFormatter = DateFormatter()

        // Set Date/Time Style
        dateFormatter.dateFormat = "M/d/y, HH:mm:ss"

        // Convert Date to String
        return dateFormatter.string(from: input)
    }
}

//
//  MoodUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/6/22.
//

import Foundation
import SwiftUI

class MoodUtils {
    public static func calculateMood(hrv: Double?) -> Color {
        if hrv != nil {
            if hrv! <= Settings.MoodDangerHRVThreshold {
                return Color.red
            }
            else if hrv! <= Settings.MoodWarningHRVThreshold {
                return Color.yellow
            }
            // above warning threshold
            else {
                return Color.green
            }
        }
        return Color("Color")
    }
}

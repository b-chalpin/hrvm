//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/15/22.
//

import Foundation

class ThreatDetector : ObservableObject {
    // singleton
    public static let shared: ThreatDetector = ThreatDetector()
    
    @Published var threatDetected: Bool = false
    @Published var threatAcknowledged: Bool = false
    
    public func checkHrvForThreat(hrv: HrvItem) {
        if self.predict(hrv: hrv.value) {
            threatDetected = true
        }
    }
    
    // this method changed to detect if the threat was actaully acknowledged or not
    public func acknowledgeThreat(feedback: Bool) {
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
    }
    
    // returns true for danger; false otherwise
    public func predict(hrv: Double) -> Bool {
        return hrv <= Settings.DangerHRVThreshold
    }
}

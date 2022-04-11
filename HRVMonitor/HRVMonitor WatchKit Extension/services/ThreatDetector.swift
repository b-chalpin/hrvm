//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/15/22.
//

import Foundation
import WatchKit

class ThreatDetector : ObservableObject {
    @Published var threatDetected: Bool = false
    
    private let notificationFactory = NotificationFactory()
    
    public func checkHrvForThreat(hrv: HrvItem) {
        if self.predict(hrv: hrv.value) {
            threatDetected = true
            
            // notify user
            WKInterfaceDevice.current().play(.failure)
            self.notificationFactory.pushNotification()
            
        }
    }
    
    // method to reset threatDetected var
    public func acknowledgeThreat() {
        print("Threat acked")
        self.threatDetected = false
    }
    
    // returns true for danger; false otherwise
    public func predict(hrv: Double) -> Bool {
        return hrv <= Settings.DangerHRVThreshold
    }
}

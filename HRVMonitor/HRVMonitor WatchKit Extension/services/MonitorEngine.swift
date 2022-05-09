//
//  MonitorEngine.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/14/22.
//

import Foundation
import SwiftUI

// @deprecated
enum MonitorEngineStatus {
    case stopped
    case starting
    case active
}

class MonitorEngine : ObservableObject {
    // dependency injected modules
    private var hrPoller: HeartRatePoller? = nil
    private var threatDetector: ThreatDetector? = nil
    private var alertNotificationHandler: AlertNotificationHandler? = nil
    
    private var workoutManager = WorkoutManager()
    private var monitorTimer: Timer?
    
    // @deprecated
    // UI will be subscribed to this status
    @Published var status: MonitorEngineStatus = .stopped
    
    public func bind(hrPoller: HeartRatePoller, threatDetector: ThreatDetector, alertNotificationHandler: AlertNotificationHandler) {
        self.hrPoller = hrPoller
        self.threatDetector = threatDetector
        self.alertNotificationHandler = alertNotificationHandler
    }
    
    public func stopMonitoring() {
        // @deprecated
        self.status = .stopped
        
        // end workout
        self.workoutManager.endWorkout()
        
        // stop hr poller
        self.stopMonitorTimer()
        self.hrPoller!.stopPolling()
    }
    
    public func startMonitoring() {
        // @deprecated
        self.status = .starting
        
        // start workout
        self.workoutManager.startWorkout()
        
        // hr poller
        self.hrPoller!.initPolling() // get hrPoller ready for polling
        self.initMonitorTimer() // this handles synchronous polling
    }
    
    private func initMonitorTimer() {
        if self.monitorTimer?.isValid == true {
            print("ERROR - Timer already started")
            return
        }

        self.monitorTimer = Timer.scheduledTimer(withTimeInterval: Settings.HRVMonitorIntervalSec, repeats: true, block: {_ in
            if Settings.DemoMode {
                self.hrPoller!.demo()
            }
            else {
                self.hrPoller!.poll()
            }
            
            if self.hrPoller!.isActive() { // if true then latestHrv is defined
                self.status = .active // update monitor engine status @deprecated
                self.threatDetector!.checkHrvForThreat(hrv: self.hrPoller!.latestHrv!)
                
                if(self.threatDetector!.threatDetected && self.alertNotificationHandler!.appState == .foreground)
                {
                    self.threatDetector!.threatDetected = false
                    self.alertNotificationHandler!.alert = true
                }
                else if(self.threatDetector!.threatDetected && self.alertNotificationHandler!.appState == .background)
                {
                    self.threatDetector!.threatDetected = false
                    self.alertNotificationHandler!.alert = false
                    self.alertNotificationHandler!.notify()
                }
            }
        })
    }
    
    private func stopMonitorTimer() {
        self.monitorTimer?.invalidate()
        self.monitorTimer = nil
        print("LOG - Monitor timer stopped")
    }
}

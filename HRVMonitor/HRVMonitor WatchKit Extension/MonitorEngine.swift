//
//  MonitorEngine.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/14/22.
//

import Foundation
import SwiftUI

enum MonitorEngineStatus {
    case stopped
    case starting
    case active
}

class MonitorEngine : ObservableObject {
    // dependency injected modules
    private var hrPoller: HeartRatePoller
    private var threatDetector: ThreatDetector
    
    private var workoutManager = WorkoutManager()
    private var monitorTimer: Timer?
    
    // UI will be subscribed to this status
    @Published var status: MonitorEngineStatus
    
    init(hrPoller: HeartRatePoller, threatDetector: ThreatDetector) {
        self.status = .stopped
        self.hrPoller = hrPoller
        self.threatDetector = threatDetector
    }
    
    
    public func stopMonitoring() {
        self.status = .stopped
        
        // end workout
        self.workoutManager.endWorkout()
        
        // stop hr poller
        self.stopMonitorTimer()
        self.hrPoller.stopPolling()
    }
    
    public func startMonitoring() {
        self.status = .starting
        
        // start workout
        self.workoutManager.startWorkout()
        
        // hr poller
        self.hrPoller.initPolling() // get hrPoller ready for polling
        self.initMonitorTimer() // this handles synchronous polling
    }
    
    private func initMonitorTimer() {
        if self.monitorTimer?.isValid == true {
            print("ERROR - Timer already started")
            return
        }

        self.monitorTimer = Timer.scheduledTimer(withTimeInterval: Settings.HRVMonitorIntervalSec, repeats: true, block: {_ in
            if Settings.DemoMode {
                self.hrPoller.demo()
            }
            else {
                self.hrPoller.poll()
            }
            
            if self.hrPoller.isActive() { // if true then latestHrv is defined
                self.status = .active // update monitor engine status
                self.threatDetector.checkHrvForThreat(hrv: self.hrPoller.latestHrv!)
            }
        })
    }
    
    private func stopMonitorTimer() {
        self.monitorTimer?.invalidate()
        self.monitorTimer = nil
        print("LOG - Monitor timer stopped")
    }
}

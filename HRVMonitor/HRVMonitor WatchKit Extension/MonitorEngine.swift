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
    @Published var hrPoller = HeartRatePoller()
    @Published var threatDetector = ThreatDetector()
    private var workoutManager = WorkoutManager()
    @State var monitorTimer: Timer?
    
    // UI will be subscribed to this status
    @Published var status: MonitorEngineStatus = .stopped
    
    public func stopMonitoring() {
        self.status = .stopped
        
        self.workoutManager.endWorkout()
        self.stopMonitorTimer()
        self.hrPoller.stopPolling()
    }
    
    public func startMonitoring() {
        self.status = .starting
        
        self.workoutManager.startWorkout()
        self.initMonitorTimer() // this handles starting polling
    }
    
    private func initMonitorTimer() {
        if self.monitorTimer?.isValid == true {
            print("ERROR - Timer already started")
            return
        }
        
        self.monitorTimer = Timer.scheduledTimer(withTimeInterval: HRV_MONITOR_INTERVAL_SEC, repeats: true, block: {_ in
             self.hrPoller.poll()
            
            if self.hrPoller.isActive() { // if true then latestHrv is defined
                self.status = .active // update monitor engine status
                self.threatDetector.checkHrvForThreat(hrv: self.hrPoller.latestHrv!)
            }
        })
    }
    
    private func stopMonitorTimer() {
        self.monitorTimer?.invalidate()
        self.monitorTimer = nil
    }
}

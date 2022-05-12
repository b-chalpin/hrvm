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
    // singleton
    static let shared: MonitorEngine = MonitorEngine()
    
    // dependency injected modules
    private var hrPoller = HeartRatePoller.shared
    private var threatDetector = ThreatDetector.shared
    private var alertNotificationHandler = AlertNotificationHandler.shared
    
    private var workoutManager = WorkoutManager()
    private var monitorTimer: Timer?
    
    // vars to store hrv and hrvstore for event
    private var hrvSnapshotForEvent: HrvItem?
    private var hrvStoreSnapshotForEvent: [HrvItem] = []

    public func stopMonitoring() {
        // end workout
        self.workoutManager.endWorkout()
        
        // stop hr poller
        self.stopMonitorTimer()
        self.hrPoller.stopPolling()
    }
    
    public func startMonitoring() {
        
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
                self.threatDetector.checkHrvForThreat(hrv: self.hrPoller.latestHrv!)
                
                if (self.threatDetector.threatDetected) {
                    // save current HRV stuff
                    self.saveHrvSnapshotsForEvent()
                    
                    self.threatDetector.threatDetected = false
                    
                    if(self.alertNotificationHandler.appState == .foreground)
                    {
                        self.alertNotificationHandler.alert = true
                    }
                    else if(self.alertNotificationHandler.appState == .background)
                    {
                        self.alertNotificationHandler.alert = false
                        self.alertNotificationHandler.notify()
                    }
                }
                
            }
        })
    }
    
    private func saveHrvSnapshotsForEvent() {
        self.hrvSnapshotForEvent = self.hrPoller.latestHrv!
        self.hrvStoreSnapshotForEvent = self.hrPoller.hrvStore
    }
    
    private func stopMonitorTimer() {
        self.monitorTimer?.invalidate()
        self.monitorTimer = nil
        print("LOG - Monitor timer stopped")
    }
    
    public func acknowledgeThreat(feedback: Bool) {
        let currentHrvStore = self.hrvStoreSnapshotForEvent
        let currentHrv = self.hrvSnapshotForEvent! // assume app is running at this point
        
        let newEvent = EventItem(hrv: currentHrv, hrvStore: currentHrvStore, stressed: feedback)
        
        // async call to save new event (storage module)
        print("New HRV Event: \(newEvent)")
        
        // TODO: retrain model with the new HrvStore
    }
    
    public func updateAppState(phase: ScenePhase) {
        switch phase {
            case .active:
                // The app has become active.
                print(phase)
                self.alertNotificationHandler.appState = .foreground
                break

            case .inactive:
                break

            case .background:
                // The app has moved to the background.
                print(phase)
                self.alertNotificationHandler.appState = .background
                break

            @unknown default:
                fatalError("The app has entered an unknown state.")
        }
    }
}

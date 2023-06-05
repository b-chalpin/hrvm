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
    private var storageService = StorageService.shared
    
    private var workoutManager = WorkoutManager()
    private var monitorTimer: Timer?
    
    // vars to store hrv and hrvstore for event
    private var hrvSnapshotForEvent: HrvItem?
    private var hrvStoreSnapshotForEvent: [HrvItem] = []
    
    // var for notification cooldown
    private var isAlertCoolingDown: Bool = false
    private var notifyCooldownTimer: Timer?

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
                self.hrPoller.demo() // will generate random hrv values (RNG)
            }
            else {
                self.hrPoller.poll()
            }
            
            if self.hrPoller.isActive() { // if true then latestHrv is defined
                if (self.isPredicting()) { // do not predict until hrv store is at capacity
                    let predictedThreat = self.threatDetector.checkHrvForThreat(hrvStore: self.hrPoller.hrvStore) // predict threat level with new hrv store
                    self.notifyUserIfThreatDetected(threatDetected: predictedThreat)
                }
            }
        })
    }
    
    public func isPredicting() -> Bool {
        return self.hrPoller.hrvStore.count == Settings.HRVStoreSize && self.hrPoller.isActive()
    }
    
    private func stopMonitorTimer() {
        self.monitorTimer?.invalidate()
        self.monitorTimer = nil
        print("LOG - Monitor timer stopped")
    }
    
    private func saveHrvSnapshotsForEvent() {
        self.hrvSnapshotForEvent = self.hrPoller.latestHrv!
        self.hrvStoreSnapshotForEvent = self.hrPoller.hrvStore
    }
    
    private func notifyUserIfThreatDetected(threatDetected: Bool) {
        if (threatDetected && !self.isAlertCoolingDown) {
            self.saveHrvSnapshotsForEvent() // save current HRV and HRV Store

            WKInterfaceDevice.current().play(.failure)
            
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
    
    public func acknowledgeThreat(feedback: Bool, manuallyAcked: Bool) {
        var currentHrvStore: [HrvItem]
        var currentHrv: HrvItem
        
        if (manuallyAcked) {
            currentHrvStore = self.hrPoller.hrvStore
            currentHrv = self.hrPoller.latestHrv!
        }
        else { // NOT manually acked -- acked by either alert or notification
            // if threat ack is NOT purposefully triggered, start alert cooldown
            self.startCooldownTimer()
            
            currentHrvStore = self.hrvStoreSnapshotForEvent
            currentHrv = self.hrvSnapshotForEvent! // assume app is running at this point
        }
        
        let newEvent = EventItem(id: UUID(),
                                 timestamp: currentHrv.timestamp,
                                 hrv: currentHrv,
                                 hrvStore: currentHrvStore,
                                 stressed: feedback)
        
        // async call to save new event (storage module)
        self.storageService.createEventItem(event: newEvent)

        self.threatDetector.acknowledgeThreat(feedback: feedback, hrvStore: currentHrvStore)
    }
    
    private func startCooldownTimer() {
        print("LOG - Starting alert cooldown timer")
        
        // set notification/alert cooldown
        self.isAlertCoolingDown = true
        
        // initialize a timer that repeats only once
        self.notifyCooldownTimer = Timer.scheduledTimer(withTimeInterval: Settings.NotificationDelaySec, repeats: false, block: { _ in
            print("LOG - Alert cooldown timer elapsed")
            self.isAlertCoolingDown = false
        })
    }
    
    public func updateAppState(phase: ScenePhase) {
        switch phase {
            case .active:
                // The app has become active.
                self.alertNotificationHandler.appState = .foreground
                break

            case .inactive:
                break

            case .background:
                // The app has moved to the background.
                self.alertNotificationHandler.appState = .background
                break

            @unknown default:
                fatalError("The app has entered an unknown state.")
        }
    }
}

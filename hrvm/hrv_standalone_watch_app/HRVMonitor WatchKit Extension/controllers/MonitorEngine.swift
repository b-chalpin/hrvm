//
//  MonitorEngine.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the `MonitorEngine` class for the HRVMonitor WatchKit Extension.
//  The `MonitorEngine` is responsible for managing the heart rate monitoring process by coordinating
//  the `HeartRatePoller`, `ThreatDetector`, `AlertNotificationHandler`, `StorageService`, and `WorkoutManager`.
//  The class is designed as a singleton to ensure a single point of access to its functionality.
//
//  Key functionalities include:
//  - Starting and stopping the monitoring process.
//  - Coordinating with the `HeartRatePoller` for heart rate polling and handling demo mode.
//  - Predicting threats using the `ThreatDetector`.
//  - Managing alert notifications and cooldowns.
//  - Acknowledging threats and saving them as events in `StorageService`.
//  - Updating the app's state for proper handling of notifications and alerts.
//
//  Created by bchalpin on 3/14/22.
//

import Foundation
import SwiftUI

/// Represents the status of the `MonitorEngine`.
enum MonitorEngineStatus {
    case stopped
    case starting
    case active
}

/// A singleton class that manages the heart rate monitoring process and threat detection.
/// It coordinates the `HeartRatePoller`, `ThreatDetector`, `AlertNotificationHandler`, `StorageService`, and `WorkoutManager`.
/// The class provides methods to start and stop the monitoring process, handle heart rate polling and threat detection, acknowledge threats, and update the app's state.
class MonitorEngine: ObservableObject {
    /// The shared instance of `MonitorEngine`.
    static let shared: MonitorEngine = MonitorEngine()
    
    private var hrPoller = HeartRatePoller.shared
    private var sitStandPoller = SitStandPoller.shared
    private var threatDetector = ThreatDetector.shared
    private var alertNotificationHandler = AlertNotificationHandler.shared
    private var storageService = StorageService.shared
    
    private var workoutManager = WorkoutManager()
    private var monitorTimer: Timer?
    
    private var hrvSnapshotForEvent: HrvItem? // Stores HRV snapshot for event
    private var hrvStoreSnapshotForEvent: [HrvItem] = [] // Stores HRV store snapshot for event
    
    private var isAlertCoolingDown: Bool = false // Flag to track alert cooldown state
    private var notifyCooldownTimer: Timer?
    
    /// Stops the monitoring process.
    public func stopMonitoring() {
        // End workout
        self.workoutManager.endWorkout()
        
        // Stop HR poller
        self.stopMonitorTimer()
        self.hrPoller.stopPolling()
    }
    
    /// Starts the monitoring process.
    public func startMonitoring() {
        // Start workout
        self.workoutManager.startWorkout()
        
        // HR poller
        self.hrPoller.initPolling() // Get HR poller ready for polling
        self.initMonitorTimer() // This handles synchronous polling
    }
    
    private func initMonitorTimer() {
        if self.monitorTimer?.isValid == true {
            print("ERROR - Timer already started")
            return
        }

        self.monitorTimer = Timer.scheduledTimer(withTimeInterval: Settings.HRVMonitorIntervalSec, repeats: true, block: { _ in
            if Settings.DemoMode {
                self.hrPoller.demo() // Generate random HRV values (RNG)
            } else {
                self.hrPoller.poll()
                self.sitStandPoller.poll() // Added call to poll sit/stand data
            }
            
            if self.hrPoller.isActive() {
                // If true, latest HRV is defined
                if self.isPredicting() {
                    // Do not predict until HRV store is at capacity
                    let predictedThreat = self.threatDetector.checkHrvForThreat(hrvStore: self.hrPoller.hrvStore)
                    self.notifyUserIfThreatDetected(threatDetected: predictedThreat)
                }
            }
        })
    }
    
    /// Checks if the `MonitorEngine` is in a predicting state.
    /// - Returns: A boolean indicating whether the `MonitorEngine` is predicting or not.
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
        if threatDetected && !self.isAlertCoolingDown {
            self.saveHrvSnapshotsForEvent() // Save current HRV and HRV Store

            WKInterfaceDevice.current().play(.failure)
            
            if self.alertNotificationHandler.appState == .foreground {
                self.alertNotificationHandler.alert = true
            } else if self.alertNotificationHandler.appState == .background {
                self.alertNotificationHandler.alert = false
                self.alertNotificationHandler.notify()
            }
        }
    }
    
    /// Acknowledges a threat.
    /// - Parameters:
    ///   - feedback: A boolean indicating whether the user provided feedback or not.
    ///   - manuallyAcked: A boolean indicating whether the threat was manually acknowledged or not.
    public func acknowledgeThreat(feedback: Bool, manuallyAcked: Bool) {
        var currentHrvStore: [HrvItem]
        var currentHrv: HrvItem
        
        if manuallyAcked {
            currentHrvStore = self.hrPoller.hrvStore
            currentHrv = self.hrPoller.latestHrv!
        } else {
            // Not manually acknowledged (acked by either alert or notification)
            self.startCooldownTimer()
            
            currentHrvStore = self.hrvStoreSnapshotForEvent
            currentHrv = self.hrvSnapshotForEvent! // Assume app is running at this point
        }
        
        let newEvent = EventItem(
            id: UUID(),
            timestamp: currentHrv.timestamp,
            hrv: currentHrv,
            hrvStore: currentHrvStore,
            isStressed: feedback,
            sitStandChange: self.sitStandPoller.sitStandChange
        )
        
        // Async call to save new event (storage module)
        self.storageService.createEventItem(event: newEvent)

        self.threatDetector.acknowledgeThreat(feedback: feedback, hrvStore: currentHrvStore)
    }
    
    private func startCooldownTimer() {
        print("LOG - Starting alert cooldown timer")
        
        // Set notification/alert cooldown
        self.isAlertCoolingDown = true
        
        // Initialize a timer that repeats only once
        self.notifyCooldownTimer = Timer.scheduledTimer(withTimeInterval: Settings.NotificationDelaySec, repeats: false, block: { _ in
            print("LOG - Alert cooldown timer elapsed")
            self.isAlertCoolingDown = false
        })
    }
    
    /// Updates the app's state based on the given `ScenePhase`.
    /// - Parameter phase: The `ScenePhase` representing the app's current phase.
    public func updateAppState(phase: ScenePhase) {
        switch phase {
        case .active:
            // The app has become active.
            self.alertNotificationHandler.appState = .foreground
        case .inactive:
            break
        case .background:
            // The app has moved to the background.
            self.alertNotificationHandler.appState = .background
        @unknown default:
            fatalError("The app has entered an unknown state.")
        }
    }
}

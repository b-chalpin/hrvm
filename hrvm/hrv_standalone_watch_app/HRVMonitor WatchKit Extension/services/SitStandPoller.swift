//
//  SitStandPoller.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/23/22.
//

import Foundation
import HealthKit
import CoreMotion

/// Represents the current status of the SitStandPoller.
enum SitStandPollerStatus {
    case stopped
    case starting
    case active
}

/// A class responsible for polling accelerometer data and detecting sit-to-stand changes.
public class SitStandPoller: ObservableObject {
    
    // MARK: - Properties
    
    /// The shared instance of the SitStandPoller.
    public static let shared: SitStandPoller = SitStandPoller()
    
    /// Indicates whether the poller has been stopped.
    private var hasBeenStopped: Bool = true
    
    /// The latest acceleration data.
    @Published public var latestAcceleration: CMAcceleration?
    
    /// The store of acceleration values being calculated.
    @Published public var accelerationStore: [CMAcceleration]
    
    /// The current status of the SitStandPoller.
    @Published private var status: SitStandPollerStatus
    
    /// The authorization status for motion activity updates.
    @Published public var authStatus: Bool = false
    
    /// A flag indicating a change from sitting to standing.
    @Published public var sitStandChange: Bool = false
    
    // MARK: - Initialization
    
    public init() {
        self.status = .stopped
        self.latestAcceleration = nil
        self.accelerationStore = []
        self.checkAuthorization()
    }
    
    // MARK: - Public Methods
    
    /// Returns the acceleration store.
    ///
    /// - Returns: An array of CMAcceleration objects representing the acceleration store.
    public func getAccelerationStore() -> [CMAcceleration] {
        return self.accelerationStore
    }
    
    /// Checks the authorization status for motion activity updates.
    private func checkAuthorization() {
        if CMMotionActivityManager.isActivityAvailable() {
            let motionActivityManager = CMMotionActivityManager()
            motionActivityManager.queryActivityStarting(from: Date(), to: Date(), to: OperationQueue.main) { (activities, error) in
                if error != nil {
                    print("ERROR - Unable to start motion activity updates")
                } else {
                    DispatchQueue.main.async {
                        self.authStatus = true
                    }
                }
            }
        } else {
            print("ERROR - Unable to start motion activity updates. Motion activity is not available.")
        }
    }
    
    /// Checks if the SitStandPoller is active.
    ///
    /// - Returns: A boolean indicating if the SitStandPoller is active.
    public func isActive() -> Bool {
        return self.status == .active
    }
    
    /// Starts polling accelerometer data.
    public func poll() {
        if CMMotionActivityManager.isActivityAvailable() {
            let motionActivityManager = CMMotionActivityManager()
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
                // Check if the poller has been stopped before continuing
                if self.hasBeenStopped {
                    print("LOG - SitStandPoller has been told to stop. Aborting query.")
                    motionActivityManager.stopActivityUpdates()
                    return
                }
                if let activity = activity {
                    if activity.stationary {
                        // We are stationary, so we can start polling the accelerometer
                        self.updateStatus(status: .starting)
                        let motionManager = CMMotionManager()
                        motionManager.accelerometerUpdateInterval = 0.1
                        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                            if error != nil {
                                print("ERROR - Unable to start accelerometer updates.")
                            } else {
                                if let accelerometerData = accelerometerData {
                                    // We have accelerometer data, so we can start calculating the average
                                    self.updateStatus(status: .active)
                                    self.latestAcceleration = accelerometerData.acceleration
                                    self.accelerationStore.append(accelerometerData.acceleration)
                                    if self.accelerationStore.count > 10 {
                                        self.accelerationStore.removeFirst()
                                    }
                                    // Calculate the average acceleration
                                    let averageAcceleration = self.accelerationStore.reduce(CMAcceleration(x: 0, y: 0, z: 0)) { (result, acceleration) -> CMAcceleration in
                                        return CMAcceleration(x: result.x + acceleration.x, y: result.y + acceleration.y, z: result.z + acceleration.z)
                                    }
                                    let averageX = averageAcceleration.x / Double(self.accelerationStore.count)
                                    let averageY = averageAcceleration.y / Double(self.accelerationStore.count)
                                    let averageZ = averageAcceleration.z / Double(self.accelerationStore.count)
                                    // Calculate the magnitude of the average acceleration
                                    let magnitude = sqrt(pow(averageX, 2) + pow(averageY, 2) + pow(averageZ, 2))
                                    // If the magnitude is greater than 1.5, we have changed from sitting to standing
                                    if magnitude > 1.5 {
                                        self.sitStandChange = true
                                    } else {
                                        self.sitStandChange = false
                                    }
                                }
                            }
                        }
                    } else {
                        // We are not stationary, so we can stop polling the accelerometer
                        self.updateStatus(status: .stopped)
                        let motionManager = CMMotionManager()
                        motionManager.stopAccelerometerUpdates()
                        self.latestAcceleration = nil
                        self.accelerationStore = []
                    }
                }
            }
            self.updateStatus(status: .active)
        } else {
            print("ERROR - Unable to start motion activity updates. Motion activity is not available.")
        }
    }
    
    /// Stops the SitStandPoller.
    public func stop() {
        self.hasBeenStopped = true
        self.updateStatus(status: .stopped)
    }
    
    // MARK: - Private Methods
    
    /// Updates the status of the SitStandPoller.
    ///
    /// - Parameter status: The new status of the SitStandPoller.
    private func updateStatus(status: SitStandPollerStatus) {
        self.status = status
    }
}

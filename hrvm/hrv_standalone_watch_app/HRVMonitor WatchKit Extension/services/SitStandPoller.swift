import Foundation
import HealthKit
import CoreMotion

// it is assumed that when status is .active, accelerometer data will be defined
enum SitStandPollerStatus {
    case stopped
    case starting
    case active
}

public class SitStandPoller : ObservableObject {
    // singleton
    public static let shared: SitStandPoller = SitStandPoller()

    // variable to indicate whether we have notified the poller to stop
    private var hasBeenStopped: Bool = true

    @Published var latestAcceleration: CMAcceleration? // our current acceleration
    @Published var accelerationStore: [CMAcceleration] // store our acceleration values that are being calculated
    @Published var status: SitStandPollerStatus
    @Published var authStatus: Bool = false
    @Published var sitStandChange: Bool = false // flag for change from sitting to standing
    
    public init() {
        self.status = .stopped
        self.latestAcceleration = nil
        self.accelerationStore = []
        self.checkAuthorization()
    }
    
    public func getAccelerationStore() -> [CMAcceleration] {
        return self.accelerationStore
    }
    
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
    
    public func isActive() -> Bool {
        return self.status == .active
    }
    
    public func poll() {
        if CMMotionActivityManager.isActivityAvailable() {
            let motionActivityManager = CMMotionActivityManager()
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
                // there is a chance that we have stopped the polling, check this first before continuing
                if self.hasBeenStopped {
                    print("LOG - Posture Poller has been told to stop. Aborting query")
                    motionActivityManager.stopActivityUpdates()
                    return
                }
                if let activity = activity {
                    if activity.stationary {
                        // we are stationary, so we can start polling the accelerometer
                        self.updateStatus(status: .starting)
                        let motionManager = CMMotionManager()
                        motionManager.accelerometerUpdateInterval = 0.1
                        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                            if error != nil {
                                print("ERROR - Unable to start accelerometer updates")
                            } else {
                                if let accelerometerData = accelerometerData {
                                    // we have accelerometer data, so we can start calculating the average
                                    self.updateStatus(status: .active)
                                    self.latestAcceleration = accelerometerData.acceleration
                                    self.accelerationStore.append(accelerometerData.acceleration)
                                    if self.accelerationStore.count > 10 {
                                        self.accelerationStore.removeFirst()
                                    }
                                    // calculate the average acceleration
                                    let averageAcceleration = self.accelerationStore.reduce(CMAcceleration(x: 0, y: 0, z: 0)) { (result, acceleration) -> CMAcceleration in
                                        return CMAcceleration(x: result.x + acceleration.x, y: result.y + acceleration.y, z: result.z + acceleration.z)
                                    }
                                    let averageX = averageAcceleration.x / Double(self.accelerationStore.count)
                                    let averageY = averageAcceleration.y / Double(self.accelerationStore.count)
                                    let averageZ = averageAcceleration.z / Double(self.accelerationStore.count)
                                    // calculate the magnitude of the average acceleration
                                    let magnitude = sqrt(pow(averageX, 2) + pow(averageY, 2) + pow(averageZ, 2))
                                    // if the magnitude is greater than 1.5, we have changed from sitting to standing
                                    if magnitude > 1.5 {
                                        self.sitStandChange = true
                                    } else {
                                        self.sitStandChange = false
                                    }
                                }
                            }
                        }
                    } else {
                        // we are not stationary, so we can stop polling the accelerometer
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
    
    public func stop() {
        self.hasBeenStopped = true
        self.updateStatus(status: .stopped)
    }
    
    private func updateStatus(status: SitStandPollerStatus) {
        self.status = status
    }
}

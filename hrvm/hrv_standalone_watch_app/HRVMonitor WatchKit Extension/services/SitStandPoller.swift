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
    let motionActivityManager = CMMotionActivityManager()

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
    }
    
    public func isActive() -> Bool {
        return self.status == .active
    }
    
    public func poll() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] (activity) in
                guard let self = self else { return }
                
                if self.hasBeenStopped {
                    print("LOG - Posture Poller has been told to stop. Aborting query")
                    motionActivityManager.stopActivityUpdates()
                    return
                }
                
                if let activity = activity, activity.confidence == .high && activity.stationary == false {
                    let acceleration = CMAcceleration()
                    self.latestAcceleration = acceleration
                    self.accelerationStore.append(acceleration)
                    
                    // Detect change from sitting to standing
                    let accelerationMagnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
                    if accelerationMagnitude > 1.2 {
                        print("Change detected from sitting to standing")
                        self.sitStandChange = true // set flag for change from sitting to standing
                    }
                }
            }
            self.updateStatus(status: .active)
        }
        else {
            print("ERROR - Unable to poll motion data")
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

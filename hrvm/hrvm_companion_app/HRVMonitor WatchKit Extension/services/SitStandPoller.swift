import Foundation
import HealthKit
import CoreMotion

// It is assumed that when status is .active, accelerometer data will be defined
enum SitStandPollerStatus {
    case stopped
    case starting
    case active
}

public class SitStandPoller: ObservableObject {
    // Singleton
    public static let shared: SitStandPoller = SitStandPoller()

    // Variable to indicate whether we have notified the poller to stop
    private var hasBeenStopped: Bool = true

    @Published var latestAcceleration: CMAcceleration? // Our current acceleration
    @Published var accelerationStore: [CMAcceleration] // Store our acceleration values that are being calculated
    @Published var status: SitStandPollerStatus
    @Published var authStatus: Bool = false
    @Published var sitStandChange: Bool = false // Flag for change from sitting to standing

    private let healthStore: HKHealthStore // HealthKit store

    public init() {
        self.status = .stopped
        self.latestAcceleration = nil
        self.accelerationStore = []
        self.healthStore = HKHealthStore() // Initialize HealthKit store
        self.checkAuthorization()
    }

    public func getAccelerationStore() -> [CMAcceleration] {
        return self.accelerationStore
    }

    private func checkAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if !success {
                print("ERROR - Unable to request HealthKit authorization. \(error?.localizedDescription ?? "")")
            }
            self.authStatus = success
        }
    }

    public func isActive() -> Bool {
        return self.status == .active
    }

    public func poll() {
        self.hasBeenStopped = false
        self.updateStatus(status: .starting)

        let motionActivityManager = CMMotionActivityManager()
        motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
            if activity != nil {
                if activity!.stationary {
                    self.updateStatus(status: .active)
                    self.starting()
                } else {
                    self.updateStatus(status: .stopped)
                    self.stop()
                }
            }
        }
    }

    public func stop() {
        self.hasBeenStopped = true
        self.updateStatus(status: .stopped)
    }

    private func starting() {
        self.accelerationStore = []
        self.sitStandChange = false
        self.latestAcceleration = nil

        let motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
            if error != nil {
                print("ERROR - Unable to get accelerometer data. \(error!.localizedDescription)")
            } else {
                if accelerometerData != nil {
                    self.latestAcceleration = accelerometerData!.acceleration
                    self.accelerationStore.append(accelerometerData!.acceleration)

                    if self.accelerationStore.count > 10 {
                        self.accelerationStore.removeFirst()
                    }

                    if self.accelerationStore.count == 10 {
                        let avgAcceleration = self.getAverageAcceleration()
                        if avgAcceleration > 1.0 {
                            self.sitStandChange = true
                        }
                    }
                }
            }
        }
    }

    private func getAverageAcceleration() -> Double {
        var sum: Double = 0.0
        for acceleration in self.accelerationStore {
            sum += acceleration.x
        }
        return sum / Double(self.accelerationStore.count)
    }

    private func updateStatus(status: SitStandPollerStatus) {
        self.status = status
    }
}
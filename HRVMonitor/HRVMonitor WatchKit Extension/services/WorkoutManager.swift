//
//  Workout mode.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Jared Adams on 3/11/22.
//

import Foundation
import HealthKit

class WorkoutManager {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?

    public func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .indoor

        // create the session and obtain the workout builder
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            print("ERROR - failed to create workout session")
            return
        }

        // start the workout session and begin data collection
        let startDate = Date()
        session?.startActivity(with: startDate)
    }

    public func pause() {
        session?.pause()
    }

    public func resume() {
        session?.resume()
    }

    public func endWorkout() {
        session?.end()
    }
}

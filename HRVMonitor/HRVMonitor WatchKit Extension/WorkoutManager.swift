//
//  Workout mode.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Jared Adams on 3/11/22.
//

import Foundation
import HealthKit


class WorkoutManager: NSObject {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?

    // Start the workout.
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .indoor

        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            print("Error: failed to create workout session")
            return
        }

        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func endWorkout() {
        session?.end()
    }
}

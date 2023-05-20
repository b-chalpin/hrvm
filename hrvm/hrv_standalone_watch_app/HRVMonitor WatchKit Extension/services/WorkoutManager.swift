//
//  WorkoutManager.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Jared Adams on 3/11/22.
//

import Foundation
import HealthKit

/// A manager class for handling workout sessions.
class WorkoutManager {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    
    /// Starts a workout session with default configuration.
    ///
    /// This method creates a workout session with an activity type of running and a location type of indoor.
    /// It then starts the workout session and begins data collection.
    public func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
            print("ERROR - Failed to create workout session")
            return
        }
        
        let startDate = Date()
        session?.startActivity(with: startDate)
    }
    
    /// Pauses the current workout session.
    public func pause() {
        session?.pause()
    }
    
    /// Resumes the current workout session.
    public func resume() {
        session?.resume()
    }
    
    /// Ends the current workout session.
    public func endWorkout() {
        session?.end()
    }
}

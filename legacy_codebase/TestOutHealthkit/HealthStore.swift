//
//  HealthStore.swift
//  TestOutHealthkit WatchKit Extension
//
//  Created by EWU Team5 on 9/29/21.
//

import Foundation
import HealthKit


class HealthStore {
    var healthStore : HKHealthStore?
    var query : HKAnchoredObjectQuery?//HKStatisticsCollectionQuery?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        guard let healthStore = self.healthStore else { return completion(false) }
        
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { (success, error) in
            completion(success)
        }
    }
    
    func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: [])
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        query = HKAnchoredObjectQuery(type: type!, predicate: predicate, anchor: .none, limit: 0) { (query, samples, deletedObjects, anchor, error) -> Void in
            
        }
        
        print("Start the workout session")
        
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = HKWorkoutActivityType.mindAndBody
        workoutConfig.locationType = HKWorkoutSessionLocationType.indoor
        
        var workoutSession = try? HKWorkoutSession(healthStore: healthStore!, configuration: workoutConfig)
       
        //workoutSession!.delegate = self
       
        workoutSession!.startActivity(with: Date())
       
        let typesToShare = Set([HKObjectType.workoutType()])
        let typesToRead = Set([
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            ])
       
        healthStore!.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) -> Void in
            print(success)
            print(error)
        }
        
        //
        // NEW STUFF HERE!!!!
        //
        query!.updateHandler = {
            (query, samples, deletedObjects, anchor, error) -> Void in
           
            self.getHeartRateSamples(samples: samples)
       
        }
       
        if let healthStore = healthStore, let query = self.query {
            healthStore.execute(query)
        }
       
        let sampleHandler = { (samples: [HKQuantitySample]) -> Void in
      
        }
        
        
       
        print("Created the rolling query!!!")
    
        //return heartRateQuery
        
        //// Continue @
        //// https://youtu.be/ohgrzM9gfvM?t=1381
        //if let healthStore = healthStore, let query = self.query {
        //    healthStore.execute(query)
        //}
    }
    
    func getHeartRateSamples(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
       
        for sample in heartRateSamples {
            print(sample.quantity)
            print(sample.startDate)
           
            let heartRate = sample.quantity
        }
    }
}

//extension HealthStore: HKWorkoutSessionDelegate {
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
//        /*switch toState {
//        case .running:
//            if fromState == .notStarted {
//                heartRateManager.start()
//            }
//
//        default:
//            break
//        }*/
//    }
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
//        fatalError(error.localizedDescription)
//    }
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
//        print("Did generate \(event)")
//    }
//
//}

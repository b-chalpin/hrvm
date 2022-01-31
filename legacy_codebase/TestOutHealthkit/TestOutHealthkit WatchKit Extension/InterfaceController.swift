//
//  InterfaceController.swift
//  TestOutHealthkit WatchKit Extension
//
//  Created by Timoster the Gr9 on 11/8/21.
//

/*import Foundation
import HealthKit

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate  {
    let healthStore: HKHealthStore = HKHealthStore()
   
    @IBOutlet var label: WKInterfaceLabel!
   
    var workoutStartDate: NSDate?
    var workoutEndDate: NSDate?
   
    var queries: [HKQuery] = []
   
   
   
    var heartRateSampless: [HKQuantitySample] = []
    let countPerMinuteUnit = HKUnit(fromString: "count/min")
   
    let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
   
    var currentHeartRateSample: HKQuantitySample?
   
   
   
    var currentHeartRateQuantity: HKQuantity!
   
   
   
   
    var activityType: HKWorkoutActivityType?
    var locationType: HKWorkoutSessionLocationType?
   
    var workoutSession: HKWorkoutSession?
   
   
   
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
       
        label.setText("hasn't been updated yet")
       
        activityType = HKWorkoutActivityType.MindAndBody
       
       
        locationType = HKWorkoutSessionLocationType.Indoor
        workoutSession = HKWorkoutSession(activityType: activityType!, locationType: locationType!)
       
        workoutSession!.delegate = self
       
        healthStore.startWorkoutSession(workoutSession!) { (update, error) -> Void in
           
        }
       
        let typesToShare = Set([HKObjectType.workoutType()])
        let typesToRead = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
           
            ])
       
        self.healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) { (sucess, error) -> Void in
           
          
            print(sucess)
            print(error)
           
        }
       
       
        createStreamingHeartRateQuery(NSDate())
    }
   
   
    func getHeartRateSamples(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
       
        self.heartRateSampless = heartRateSamples
       
        for sample in heartRateSamples {
            print(sample.quantity)
            print(sample.startDate)
           
            let heartRate = sample.quantity
            let heartRateDouble = heartRate.doubleValueForUnit(countPerMinuteUnit)
           
            self.label.setText("\(heartRateDouble)")
           
        }
    }
   
   
    func createStreamingHeartRateQuery(workoutStartDate: NSDate) -> HKQuery {
       
       
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        let type = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let heartRateQuery = HKAnchoredObjectQuery(type: type!, predicate: predicate, anchor: 0, limit: 0) { (query, samples, deletedObjects, anchor, error) -> Void in
           
        }
       
        heartRateQuery.updateHandler = {
            (query, samples, deletedObjects, anchor, error) -> Void in
           
            self.getHeartRateSamples(samples)
       
        }
       
        healthStore.executeQuery(heartRateQuery)
       
        let sampleHandler = { (samples: [HKQuantitySample]) -> Void in
      
        }
       
    
        return heartRateQuery
       
    }
   
   
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
       
       
       
    }
   
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
       
       
    }
   
}*/

//
//  StorageService.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/13/22.
//

import Foundation
import CoreData

public class StorageService : ObservableObject {
    // singleton pattern
    static let shared = StorageService()
    
    private let context = PersistenceController.shared.container.viewContext
    
    public func createStressEvent(event: EventItem) {
        let newEvent = StressEvent(context: context)
        
        newEvent.id = event.id
        newEvent.timestamp = event.timestamp
//        newEvent.hrv = event.hrv
//        newEvent.hrvStore = event.hrvStore as NSObject
        newEvent.label = event.stressed
        
        self.saveContext()
    }
    
    public func getAllStressEvents() -> [EventItem] {
        let request = NSFetchRequest<StressEvent>(entityName: "StressEvent")
        
        do {
            let storedEvents = try context.fetch(request)
            
            return storedEvents.map { (event) -> EventItem in
                let dummyHrv = HrvItem(value: 0, timestamp: Date(), deltaHrvValue: 0.0, deltaUnixTimestamp: 0.0, avgHeartRateMS: 0.0, numHeartRateSamples: 1, hrSamples: []) // stub out for now
                
                return EventItem(id: event.id!,
                                 timestamp: event.timestamp!,
                                 hrv: dummyHrv,
                                 hrvStore: [dummyHrv],
                                 stressed: event.label)
            }
        }
        catch {
            fatalError("Fatal error occurred fetching all events")
        }
    }
    
    private func saveContext() {
      if context.hasChanges {
        do {
          try context.save()
        } catch {
            if let nserror = error as NSError? {
                fatalError("Unable to save context - \(nserror.userInfo) - \(nserror)")
            }
        }
      }
    }
}

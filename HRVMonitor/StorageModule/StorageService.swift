//
//  StorageService.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/13/22.
//

import Foundation

class StorageService {
    public let shared = StorageService()
    
    private let context = PersistenceController.shared.container.viewContext
    
    public func createNewEvent(event: EventItem) {
//        let newEvent = StressEvent
        // stuff here
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

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
    
    public func createHrvReading(hrvItem: HrvItem) {      
        let newHrvReading = HrvReading(context: context)
        
        // critical data
        newHrvReading.hrv = hrvItem.value
        newHrvReading.timestamp = hrvItem.timestamp
        newHrvReading.unixTimestamp = hrvItem.unixTimestamp
        
        // hr data
        newHrvReading.avgHeartRateBPM = hrvItem.avgHeartRateBPM
        newHrvReading.avgHeartRateMS = hrvItem.avgHeartRateMS
        newHrvReading.hrSamples = JsonSerializerUtils.serialize(data: hrvItem.hrSamples)
        
        // delta values
        newHrvReading.deltaHrv = hrvItem.deltaHrvValue
        newHrvReading.deltaUnixTimestamp = hrvItem.deltaUnixTimestamp
        
        self.saveContext()
    }
    
    // function for settings view to use on initialization
    public func getPatientSettings() -> PatientSettings {
        let userSetting = self.fetchSingleUserSetting()
        
        if (userSetting == nil) {
            return DEFAULT_PATIENT_SETTINGS
        }
        else {
            return PatientSettings(age: Int(userSetting!.age), sex: userSetting!.sex!)
        }
    }
    
    public func updateUserSettings(patientSettings: PatientSettings) {
        var currentUserSetting = self.fetchSingleUserSetting()
        
        if (currentUserSetting == nil) { // if we do not fetch a user setting, it does not exist yet
            // create new user setting record
            currentUserSetting = UserSetting(context: context)
        }
        
        currentUserSetting!.age = Int16(patientSettings.age)
        currentUserSetting!.sex = patientSettings.sex

        self.saveContext()
    }
    
    private func fetchSingleUserSetting() -> UserSetting? {
        let request = NSFetchRequest<UserSetting>(entityName: "UserSetting")

        do {
            return try context.fetch(request).first
        }
        catch {
            fatalError("Fatal error occurred fetching global user setting")
        }
    }
    
    public func createStressEvent(event: EventItem) {
        let newEvent = StressEvent(context: context)
        
        newEvent.id = event.id
        newEvent.timestamp = event.timestamp
        newEvent.hrv = JsonSerializerUtils.serialize(data: event.hrv)
        newEvent.hrvStore = JsonSerializerUtils.serialize(data: event.hrvStore)
        newEvent.label = event.stressed
        
        self.saveContext()
    }
    
    public func getAllStressEvents() -> [EventItem] {
        let request = NSFetchRequest<StressEvent>(entityName: "StressEvent")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // sort descending of timestamp
        
        do {
            let storedEvents = try context.fetch(request)
            return mapStressEventsToEventItems(stressEvents: storedEvents)
        }
        catch {
            fatalError("Fatal error occurred fetching all events")
        }
    }
    
    public func getPageOfEventsForOffset(offset: Int) -> [EventItem] {
        let request = NSFetchRequest<StressEvent>(entityName: "StressEvent")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // sort descending of timestamp
        request.fetchLimit = Settings.StressEventPageSize
        request.fetchOffset = offset
        
        do {
            let storedEvents = try context.fetch(request)
            return mapStressEventsToEventItems(stressEvents: storedEvents)
        }
        catch {
            fatalError("Fatal error occurred fetching page of stress events for (offset: \(offset)")
        }
    }
    
    private func mapStressEventsToEventItems(stressEvents: [StressEvent]) -> [EventItem] {
        return stressEvents.map { (event) -> EventItem in
            // deserialize stored JSON to objects
            let hrvItem = JsonSerializerUtils.deserialize(jsonString: event.hrv!) as HrvItem
            let hrvStore = JsonSerializerUtils.deserialize(jsonString: event.hrvStore!) as [HrvItem]
            
            return EventItem(id: event.id!,
                             timestamp: event.timestamp!,
                             hrv: hrvItem,
                             hrvStore: hrvStore,
                             stressed: event.label)
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

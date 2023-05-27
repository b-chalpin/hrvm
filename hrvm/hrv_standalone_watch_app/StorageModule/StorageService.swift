//
//  StorageService.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines a StorageService class for an HRVMonitor WatchKit Extension,
//  which manages storage and retrieval of heart rate variability (HRV) data, patient settings,
//  events, and logistic regression (LR) model data using Core Data. The class is designed as
//  a singleton, providing a single point of access to the storage functionality.
//
//  Key functionalities include:
//
//  - HRV APIs:
//    * createHrvItem(hrvItem: HrvItem): Creates and saves a new HRV item in Core Data.
//
//  - Patient Settings APIs:
//    * getPatientSettings() -> PatientSettings: Retrieves the patient's settings.
//    * updateUserSettings(patientSettings: PatientSettings): Updates the patient's settings.
//
//  - Event APIs:
//    * createEventItem(event: EventItem): Creates and saves a new event item in Core Data.
//    * getAllStressEvents() -> [EventItem]: Retrieves all stored stress events.
//    * getPageOfEventsForOffset(offset: Int) -> [EventItem]: Retrieves a page of stress events for the given offset.
//
//  - LR APIs:
//    * getLRDataStore() -> LRDataStore: Retrieves the logistic regression data store.
//    * saveLRDataStore(datastore: LRDataStore): Saves the logistic regression data store.
//    * getLRWeights() -> [Double]: Retrieves the logistic regression weights.
//    * saveLRWeights(lrWeights: [Double]): Saves the logistic regression weights.
//
//  - Export APIs:
//    * exportAllDataToJson() -> String: Exports all data to a JSON string.
//
//  The class also contains utility methods for fetching, mapping, and saving entities in Core Data.
//
//  Created by bchalpin on 5/13/22.
//


import Foundation
import CoreData

public class StorageService: ObservableObject {
    // singleton pattern
    static let shared = StorageService()
    
    private let context = PersistenceController.shared.container.viewContext
    
    // MARK: - HRV APIs
    public func createHrvItem(hrvItem: HrvItem) {
        let newHrvReading = CD_HrvItem(context: context)
        
        // critical data
        newHrvReading.hrv = hrvItem.RMSSD
        newHrvReading.timestamp = hrvItem.timestamp
        newHrvReading.unixTimestamp = hrvItem.unixTimestamp
        
        // hr data
        newHrvReading.avgHeartRateBPM = hrvItem.avgHeartRateBPM
        newHrvReading.avgHeartRateMS = hrvItem.avgHeartRateMS
        newHrvReading.hrSamples = JsonSerializerUtils.serialize(data: hrvItem.hrSamples)
        newHrvReading.meanRR = hrvItem.meanRR
        newHrvReading.medianRR = hrvItem.medianRR
        newHrvReading.pNN50 = hrvItem.pNN50
        
        // delta values
        newHrvReading.deltaHrv = hrvItem.deltaHrvValue
        newHrvReading.deltaUnixTimestamp = hrvItem.deltaUnixTimestamp
        
        self.saveContext()
    }
    
    // MARK: - Patient Settings APIs
    // function for settings view to use on initialization
    public func getPatientSettings() -> PatientSettings {
        let userSetting = self.fetchSingleStoredPatientSettings()
        
        if userSetting == nil {
            return DEFAULT_PATIENT_SETTINGS
        } else {
            return PatientSettings(age: Int(userSetting!.age), sex: userSetting!.sex!)
        }
    }
    
    public func updateUserSettings(patientSettings: PatientSettings) {
        var currentUserSetting = self.fetchSingleStoredPatientSettings()
        
        if currentUserSetting == nil { // if we do not fetch a user setting, it does not exist yet
            // create new user setting record
            currentUserSetting = CD_PatientSettings(context: context)
        }
        
        currentUserSetting!.age = Int16(patientSettings.age)
        currentUserSetting!.sex = patientSettings.sex
        
        self.saveContext()
    }
    
    private func fetchSingleStoredPatientSettings() -> CD_PatientSettings? {
        let request: NSFetchRequest<CD_PatientSettings> = CD_PatientSettings.fetchRequest()
        
        do {
            return try context.fetch(request).first
        } catch {
            fatalError("Fatal error occurred fetching global user setting")
        }
    }
    
    // MARK: - Event APIs
    public func createEventItem(event: EventItem) {
        let newEvent = CD_EventItem(context: context)
        
        newEvent.id = event.id
        newEvent.timestamp = event.timestamp
        newEvent.hrv = JsonSerializerUtils.serialize(data: event.hrv)
        newEvent.hrvStore = JsonSerializerUtils.serialize(data: event.hrvStore)
        newEvent.isStressed = event.isStressed
        //newEvent.sitStandChange = event.sitStandChange
        
        self.saveContext()
    }
    
    public func getAllStressEvents() -> [EventItem] {
        let request: NSFetchRequest<CD_EventItem> = CD_EventItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // sort descending of timestamp
        
        do {
            let storedEvents = try context.fetch(request)
            return mapCDEventItemsToEventItems(stressEvents: storedEvents)
        } catch {
            fatalError("Fatal error occurred fetching all events")
        }
    }
    
    public func getPageOfEventsForOffset(offset: Int) -> [EventItem] {
        let request: NSFetchRequest<CD_EventItem> = CD_EventItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // sort descending of timestamp
        request.fetchLimit = Settings.StressEventPageSize
        request.fetchOffset = offset
        
        do {
            let storedEvents = try context.fetch(request)
            return mapCDEventItemsToEventItems(stressEvents: storedEvents)
        } catch {
            fatalError("Fatal error occurred fetching page of stress events for (offset: \(offset)")
        }
    }
    
    private func mapCDEventItemsToEventItems(stressEvents: [CD_EventItem]) -> [EventItem] {
        return stressEvents.map { event -> EventItem in
            guard let hrvItemData = event.hrv?.data(using: .utf8),
                  let hrvStoreData = event.hrvStore?.data(using: .utf8),
                  let hrvItem = try? JSONDecoder().decode(HrvItem.self, from: hrvItemData),
                  let hrvStore = try? JSONDecoder().decode([HrvItem].self, from: hrvStoreData) else {
                fatalError("Failed to deserialize HRV data for EventItem")
            }
            
            return EventItem(id: event.id!,
                             timestamp: event.timestamp!,
                             hrv: hrvItem,
                             hrvStore: hrvStore,
                             isStressed: event.isStressed,
                             sitStandChange: event.sitStandChange)
        }
    }


    // MARK: - LR APIs
    public func getLRDataStore() -> LRDataStore {
        let cd_lrDataStore = self.fetchSingleLRDataStore()

        if cd_lrDataStore == nil { // if nil, we do not have an LR Data Store yet
            return LRDataStore()
        } else {
            let lrDataStore = LRDataStore()

            if let jsonString = cd_lrDataStore!.dataItems, let data = jsonString.data(using: .utf8) {
                do {
                    lrDataStore.dataItems = try JSONDecoder().decode([LRDataItem].self, from: data)
                } catch {
                    print("Failed to deserialize LRDataStore: \(error)")
                }
            }
            
            lrDataStore.size = Int(cd_lrDataStore!.size)
            lrDataStore.stressCount = Int(cd_lrDataStore!.stressCount)
            
            return lrDataStore
        }
    }


    public func saveLRDataStore(datastore: LRDataStore) {
        var currentLrDataStore = self.fetchSingleLRDataStore()
        
        if currentLrDataStore == nil { // if we do not fetch a data store, it does not exist yet
            // create new data store
            currentLrDataStore = CD_LRDataStore(context: context)
        }
        
        currentLrDataStore!.dataItems = JsonSerializerUtils.serialize(data: datastore.dataItems)
        currentLrDataStore!.size = Int16(datastore.size)
        currentLrDataStore!.stressCount = Int16(datastore.stressCount)
        
        print("Saving LR Data Store: \(currentLrDataStore!.dataItems!)")
        
        self.saveContext()
    }
    
    // returns the CoreData entity for our single LR Data Store
    public func fetchSingleLRDataStore() -> CD_LRDataStore? {
        let request: NSFetchRequest<CD_LRDataStore> = CD_LRDataStore.fetchRequest()
        
        do {
            return try context.fetch(request).first
        } catch {
            fatalError("Fatal error occurred fetching global LR Data Store")
        }
    }
    
    public func getLRWeights() -> [Double] {
        let cd_lrWeights = self.fetchSingleLrWeights()
        
        if cd_lrWeights == nil { // if nil, crash and burn
            fatalError("Unexpected results when fetching global LR Weights. No weights were found.")
        }
        
        return cd_lrWeights!.weights!
    }
    
    public func saveLRWeights(lrWeights: [Double]) {
        var currentLrWeights = self.fetchSingleLrWeights()
        
        if currentLrWeights == nil { // if we do not fetch a data store, it does not exist yet
            // create new data store
            currentLrWeights = CD_LRWeights(context: context)
        }
        
        currentLrWeights!.weights = lrWeights
        
        self.saveContext()
    }
    
    // returns the CoreData entity for our single LR Data Store
    public func fetchSingleLrWeights() -> CD_LRWeights? {
        let request: NSFetchRequest<CD_LRWeights> = CD_LRWeights.fetchRequest()
        
        do {
            return try self.context.fetch(request).first
        } catch {
            fatalError("Fatal error occurred fetching global LR Weights")
        }
    }
    
    // MARK: - Export APIs
    public func exportAllDataToJson() -> String {
        let dataToExport = ExportedEntities()
        
        // for now, we will only export the data store and stress events
        dataToExport.lrDataStore = self.getLRDataStore()
        dataToExport.eventItems = self.getAllStressEvents()
        
        return JsonSerializerUtils.serialize(data: dataToExport)
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    if let nserror = error as NSError? {
                        fatalError("Unable to save context - \(nserror.userInfo) - \(nserror)")
                    }
                }
            }
        }
    }
}

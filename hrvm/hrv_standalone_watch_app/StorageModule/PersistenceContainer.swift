//
//  PersistenceContainer.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/13/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AppModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unable to load persistent stores - \(error.userInfo) - \(error)")
            }
        })
    }
}

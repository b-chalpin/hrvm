//
//  PersistantContainer.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 05/05/2022.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container = NSPersistentCloudKitContainer(name: "Models")

    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

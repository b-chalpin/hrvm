//
//  HRExtractionApp_iOS_v2App.swift
//  HRExtractionApp_iOS_v2
//
//  Created by Timoster the Gr9 on 2/28/22.
//

import SwiftUI

@main
struct HRExtractionApp_iOS_v2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

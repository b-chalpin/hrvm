//
//  dataApp.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 05/05/2022.
//

import SwiftUI

@main
struct dataApp: App {
    let container = PersistenceController.shared.container
    @Environment(\.managedObjectContext) var context
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            //
            .environment(\.managedObjectContext, container.viewContext)

        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

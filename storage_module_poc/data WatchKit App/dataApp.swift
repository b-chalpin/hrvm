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
    //Getting from the environment
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentation
    
    //This allows for editing the date inside of the data
    var modelItem: Items?
    
    
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

//
//  HRExtractionAPPApp.swift
//  HRExtractionAPP WatchKit Extension
//
//  Created by Timoster the Gr9 on 2/25/22.
//

import SwiftUI

@main
struct HRExtractionAPPApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

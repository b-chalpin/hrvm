//
//  HRVMonitorApp.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import SwiftUI

@main
struct HRVMonitorApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

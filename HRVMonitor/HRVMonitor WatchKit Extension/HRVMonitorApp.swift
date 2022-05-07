//
//  HRVMonitorApp.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI

@main
struct HRVMonitorApp: App {
    @StateObject var hrPoller: HeartRatePoller = HeartRatePoller()
    @StateObject var threatDetector: ThreatDetector = ThreatDetector()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(self.hrPoller)
                    .environmentObject(self.threatDetector)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "HRVNotification")
    }
}

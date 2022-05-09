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
    @StateObject var alertNotificationHandler: AlertNotificationHandler = AlertNotificationHandler()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(self.hrPoller)
                    .environmentObject(self.threatDetector)
                    .environmentObject(self.alertNotificationHandler)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "HRVNotification")
    }
}

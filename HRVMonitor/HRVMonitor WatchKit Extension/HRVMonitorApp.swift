//
//  HRVMonitorApp.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI

@main
struct HRVMonitorApp: App {
    @StateObject var hrPoller = HeartRatePoller.shared
    @StateObject var threatDetector = ThreatDetector.shared
    @StateObject var alertNotificationHandler = AlertNotificationHandler.shared
    @StateObject var monitorEngine = MonitorEngine.shared
    @StateObject var storageService = StorageService.shared
    
    // storage module
    private let container = PersistenceController.shared.container
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(self.hrPoller)
                    .environmentObject(self.threatDetector)
                    .environmentObject(self.alertNotificationHandler)
                    .environmentObject(self.monitorEngine)
                    .environmentObject(self.storageService)
                    .environment(\.managedObjectContext, container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "HRVNotification")
    }
}

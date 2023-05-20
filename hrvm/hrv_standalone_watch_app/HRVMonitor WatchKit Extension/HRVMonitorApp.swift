//
//  HRVMonitorApp.swift
//  HRVMonitor
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI

/// The main app struct for the HRV Monitor WatchKit Extension.
@main
struct HRVMonitorApp: App {
    @StateObject var hrPoller = HeartRatePoller.shared
    @StateObject var sitStandPoller = SitStandPoller.shared
    @StateObject var threatDetector = ThreatDetector.shared
    @StateObject var alertNotificationHandler = AlertNotificationHandler.shared
    @StateObject var monitorEngine = MonitorEngine.shared
    @StateObject var storageService = StorageService.shared
    
    // Storage module
    private let container = PersistenceController.shared.container
    
    /// The body of the app scene, including the main window and notification scene.
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

        // Notification scene for HRV notifications
        WKNotificationScene(controller: NotificationController.self, category: "HRVNotification")
    }
}

//
//  ExportApp.swift
//  Export WatchKit Extension
//
//  Created by Jared adams on 20/05/2022.
//

import SwiftUI

@main
struct ExportApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

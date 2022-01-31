//
//  TestOutHealthkitApp.swift
//  TestOutHealthkit WatchKit Extension
//
//  Created by EWU Team5 on 9/27/21.
//

import SwiftUI

@main
struct TestOutHealthkitApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

//
//  tutorial_SwiftUI_TimerWatchAppApp.swift
//  tutorial_SwiftUI_TimerWatchApp WatchKit Extension
//
//  Created by bchalpin on 2/1/22.
//

import SwiftUI

@main
struct tutorial_SwiftUI_TimerWatchAppApp: App {
//    @State private var secondScreenShown = false
//    @State private var timerVal = 15
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                HrvMonitorView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

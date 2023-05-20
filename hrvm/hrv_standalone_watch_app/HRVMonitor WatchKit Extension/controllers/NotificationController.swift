//
//  NotificationController.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import WatchKit
import SwiftUI
import UserNotifications

/// The controller responsible for handling notifications and presenting the notification interface.
class NotificationController: WKUserNotificationHostingController<NotificationView> {

    override var body: NotificationView {
        return NotificationView()
    }

    override func willActivate() {
        super.willActivate()
        // This method is called when the watch view controller is about to be visible to the user.
    }

    override func didDeactivate() {
        super.didDeactivate()
        // This method is called when the watch view controller is no longer visible.
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
    }
}

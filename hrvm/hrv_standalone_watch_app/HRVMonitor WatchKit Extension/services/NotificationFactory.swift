//
//  NotificationFactory.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 3/10/22.
//

import Foundation
import UserNotifications
import DeveloperToolsSupport

/// A factory class for creating and pushing notifications to the user.
public class NotificationFactory {
    private let center: UNUserNotificationCenter
    public var authorized: Bool
    
    /// Initializes the `NotificationFactory`.
    public init() {
        self.center = UNUserNotificationCenter.current()
        self.authorized = false
        self.getAuthorization()
    }
    
    /// Requests authorization to send notifications to the user, unless already authorized.
    private func getAuthorization() {
        if self.authorized == false {
            center.requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
                if granted {
                    self.authorized = true
                }
            }
        }
    }
    
    /// Constructs a user notification request with default content.
    ///
    /// - Returns: The constructed `UNNotificationRequest`.
    private func constructUserNotification() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "HRVAlert"
        content.categoryIdentifier = "HRVNotification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        let request = UNNotificationRequest(identifier: "HRVAlert", content: content, trigger: trigger)
        
        return request
    }
    
    /// Pushes a user notification to the user.
    ///
    /// This method requests authorization, constructs a notification, and delivers it to the user.
    public func pushNotification() {
        self.getAuthorization()
        let request = self.constructUserNotification()
        
        self.center.add(request) { error in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
        // Uncomment this block if you want to get a readout of all pending notification requests
        self.center.getPendingNotificationRequests { requests in
            for request in requests {
                print(request)
            }
        }
    }
}

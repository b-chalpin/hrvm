//
//  NotificationFactory.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 3/10/22.
//

import Foundation
import UserNotifications
import DeveloperToolsSupport

let NOTIFICATION_DELAY_SEC = 2.0

public class NotificationFactory {
    
    let center: UNUserNotificationCenter
    var authorized: Bool
    var notificationDelay: Double
    
    public init() {
        // getting the current instance of the UNUserNotificationCenter object
        self.center = UNUserNotificationCenter.current()
        self.authorized = false
        self.notificationDelay = NOTIFICATION_DELAY_SEC
    }
    
    private func getAuthorization(){
        // requesting authorization to notify user unless they already accepted
        if self.authorized == false {
            center.requestAuthorization(options: [.sound, .badge, .alert]){granted, error in
                if granted {
                    self.authorized = true
                }
            }
        }
    }
    
    private func constructUserNotification() -> UNNotificationRequest{
        //constructing the body of the notification... Need to change this to use our custom notification view
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "myCategory"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDelay, repeats: false)
        let request = UNNotificationRequest(identifier: "HRVAlert", content: content, trigger: trigger)
        
        return request
    }
    
    public func pushNotification(){
        //Public facing method which requests authorization unless the user has already accepted. Then it constructs the notification and finally delivers it.
        self.getAuthorization()
        let request = self.constructUserNotification()
        center.add(request) {(error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
}

//
//  NotificationFactory.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 3/10/22.
//

import Foundation
import UserNotifications
import DeveloperToolsSupport

public class NotificationFactory {
    private let center: UNUserNotificationCenter
    public var authorized: Bool
    
    public init() {
        // getting the current instance of the UNUserNotificationCenter object
        self.center = UNUserNotificationCenter.current()
        self.authorized = false
        self.getAuthorization()
    }
    
    private func getAuthorization(){
        // requesting authorization to notify user unless they already accepted
        if self.authorized == false {
            center.requestAuthorization(options: [.sound, .badge, .alert]){ granted, error in
                if granted {
                    self.authorized = true
                }
            }
        }
    }
    
    private func constructUserNotification() -> UNNotificationRequest{
        //constructing the body of the notification... Need to change this to use our custom notification view
        let content = UNMutableNotificationContent()
        content.title = "HRVAlert"
        content.categoryIdentifier = "HRVNotification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        let request = UNNotificationRequest(identifier: "HRVAlert", content: content, trigger: trigger)
        
        return request
    }
    
    public func pushNotification(){
        //Public facing method which requests authorization unless the user has already accepted. Then it constructs the notification and finally delivers it.
        self.getAuthorization()
        let request = self.constructUserNotification()
        
        self.center.add(request) {(error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
        // Uncomment this block if you want to get a read out of all pending notification requests
//        self.center.getPendingNotificationRequests(completionHandler: { requests in
//            for request in requests {
//                print(request)
//            }
//        })
        
    }
}

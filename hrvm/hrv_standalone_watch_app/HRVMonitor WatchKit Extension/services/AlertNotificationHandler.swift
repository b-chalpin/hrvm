//
//  AlertNotificationHandler.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/9/22.
//

import Foundation
import SwiftUI

/// Represents the state of the app.
enum AppState {
    case foreground
    case background
}

/// A handler class for managing alert notifications.
class AlertNotificationHandler: ObservableObject {
    /// The shared instance of `AlertNotificationHandler`.
    public static let shared: AlertNotificationHandler = AlertNotificationHandler()
    
    /// Indicates whether an alert is currently active or not.
    @Published var alert: Bool = false
    
    /// The current state of the app.
    @Published var appState: AppState = .foreground
    
    /// The notification factory used for pushing notifications.
    private let notificationFactory = NotificationFactory()
    
    /// Sends a notification.
    public func notify() {
        notificationFactory.pushNotification()
    }
}

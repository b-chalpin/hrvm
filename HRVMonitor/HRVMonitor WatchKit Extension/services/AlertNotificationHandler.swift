//
//  alertNotificationHandler.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 5/9/22.
//

import Foundation
import SwiftUI

enum AppState {
    case foreground
    case background
}

class AlertNotificationHandler: ObservableObject {
    @Published var alert: Bool = false
    @Published var appState: AppState = .foreground
    
    private let notificationFactory = NotificationFactory()
    
    public func notify()
    {
        self.notificationFactory.pushNotification()
    }
}

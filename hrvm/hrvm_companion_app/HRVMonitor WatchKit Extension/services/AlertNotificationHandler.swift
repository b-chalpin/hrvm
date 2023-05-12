// ======================================================================
// \title  IpCfg.hpp
// \author Nick Adams on 5/9/22.
// \brief: The AlertNotificationHandler class manages the state of an alert and handles notifications, 
// providing a simple way to notify users in the foreground or background.
//
// ======================================================================

import Foundation
import SwiftUI

enum AppState {
    case foreground
    case background
}

class AlertNotificationHandler: ObservableObject {
    // singleton
    public static let shared: AlertNotificationHandler = AlertNotificationHandler()
    
    @Published var alert: Bool = false
    @Published var appState: AppState = .foreground
    
    private let notificationFactory = NotificationFactory()
    
    public func notify()
    {
        self.notificationFactory.pushNotification()
    }
}

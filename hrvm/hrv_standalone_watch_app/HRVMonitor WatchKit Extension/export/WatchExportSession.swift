//
//  WatchExportSession.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/2/22.
//

import Foundation
import WatchConnectivity

class WatchExportSession: NSObject, WCSessionDelegate {
    // MARK: - Properties
    
    public var session: WCSession
    
    // MARK: - Initialization
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Implementation for activationDidCompleteWith method
        // Add any necessary logic or error handling here
    }
}

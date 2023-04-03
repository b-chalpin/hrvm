//
//  WatchExportSession.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/2/22.
//

import WatchConnectivity

class WatchExportSession : NSObject, WCSessionDelegate, ObservableObject {
    public var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    override init() {
        super.init()
        self.session?.delegate = self
        session?.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

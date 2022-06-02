//
//  WatchExportSession.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/2/22.
//

import WatchConnectivity

class WatchExportSession : NSObject, WCSessionDelegate {
    public var session: WCSession

    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

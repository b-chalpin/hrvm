//
//  WatchView.swift
//  Export WatchKit Extension
//
//  Created by Jared adams on 25/05/2022.
//

import Foundation
import WatchConnectivity

class WatchView : NSObject,  WCSessionDelegate{
    var session: WCSession
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

}

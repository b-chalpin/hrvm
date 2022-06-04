//
//  PhoneExportSession.swift
//  HRVMonitor
//
//  Created by bchalpin on 6/3/22.
//

import WatchConnectivity
import HealthKit
import SwiftUI


public class PhoneExportSession: NSObject, WCSessionDelegate, ObservableObject {
    public var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override init() {
        super.init()
        self.session?.delegate = self
        session?.activate()
    }
    
    // need these function headers in order to implement WCSessionDelegate
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {}
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // receive file from watch
    public func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let srcUrl = file.fileURL
        
        guard FileManager.default.fileExists(atPath: file.fileURL.path) else {
            fatalError("File transfered from Watch does not exist")
        }
        
        let destUrl = try! FileManager.default.url(for: .documentDirectory, in:.userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("export.json")
        
        // if the export.json file already exists, we must remove it
        if FileManager.default.fileExists(atPath: destUrl.path) {
            try? FileManager.default.removeItem(at: destUrl)
        }
        
        // move file from apple watch to files app
        try? FileManager.default.moveItem(at: srcUrl, to: destUrl)
    }
}

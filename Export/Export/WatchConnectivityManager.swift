//
//  WatchConnectivityManager.swift
//  Export
//
//  Created by Jared adams on 25/05/2022.
//

import Foundation
import WatchConnectivity
import HealthKit
import SwiftUI


class WatchConnectivityManager: NSObject,  WCSessionDelegate, ObservableObject{
    
    let healthStore = HKHealthStore()
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    var session: WCSession
    @Published var messageText = ""
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("Recieved message")
            self.messageText.append(message["message"] as? String ?? "Unknown")
                        do
                        {
                            let documentsDir = try FileManager.default.url(for: .documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                            print(documentsDir)
                            try self.messageText.write(to: NSURL(string:"Example.txt", relativeTo:documentsDir)! as URL, atomically:true, encoding:String.Encoding.ascii)
                        }
                        catch
                        {
                            print("Error occured")
                        }
            
        }
    }
    
}

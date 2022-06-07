//
//  HRVMonitorApp.swift
//  HRVMonitor
//
//  Created by Nick Adams on 6/2/22.
//

import SwiftUI

@main
struct HRVMonitorApp: App {
    @StateObject var phoneExportSession = PhoneExportSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.phoneExportSession)
        }
    }
}

//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit
import Charts

struct ContentView: View {
    @EnvironmentObject var monitorEngine: MonitorEngine
    @EnvironmentObject var alertNotificationHandler: AlertNotificationHandler
    
    var body: some View {
        Section {
            TabView {
                /// Page 1: HRV Monitor
                MonitorView()
                
                /// Page 2: Real-time Stats
                StatisticView()
                
                /// Page 3: Event Log
                EventLogView()
                
                /// Page 4: Export
                ExportView()
            }
        }
        .alert(isPresented: self.$alertNotificationHandler.alert) {
            Alert(
                title: Text("Are you stressed?"),
                message: Text("We have noticed a dangerous trend in your Heart Rate Variability.").font(.system(size: 10)),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.monitorEngine.acknowledgeThreat(feedback: false, manuallyAcked: false)
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.monitorEngine.acknowledgeThreat(feedback: true, manuallyAcked: false)
                    }
                )
            )
        }
    }
}

struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

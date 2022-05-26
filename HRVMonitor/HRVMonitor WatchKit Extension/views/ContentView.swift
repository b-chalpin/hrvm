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
                // page 1 - HRV monitor
                MonitorView()
                
                // page 2 - real-time stats
                StatisticView()
                
                // page 3 - event log
                EventLogView()
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


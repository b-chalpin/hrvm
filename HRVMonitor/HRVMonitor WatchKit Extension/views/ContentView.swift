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
                MonitorView().tag(0)
                
                // page 2 - real-time stats
                StatisticView().tag(1)
                
                // page 3 - event log
                EventLogView().tag(2)
            }
        }
        .alert(isPresented: self.$alertNotificationHandler.alert) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.monitorEngine.acknowledgeThreat(feedback: false)
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.monitorEngine.acknowledgeThreat(feedback: true)
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


//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit

// TODO: move these to config
let SAFE_HRV_THRESHOLD: Double = 50.00
let WARNING_HRV_THRESHOLD: Double = 30.00
let DANGER_HRV_THRESHOLD: Double = 20.0
let HRV_MONITOR_INTERVAL_SEC = 5.0

struct ContentView : View {
    @ObservedObject var monitorEngine = MonitorEngine()
    
    var body: some View {
        Form {
            Section {
                VStack{
                    Text("HRV")
                        .fontWeight(.semibold)
                        .font(.largeTitle)
                        .foregroundColor(calculateColor())
                        .multilineTextAlignment(.center)
                    Text(getHrvValueString())
                        .fontWeight(.semibold)
                        .foregroundColor(calculateColor())
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            Section {
                displayStopStartButton()
            }
        }
        .alert(isPresented: self.$monitorEngine.threatDetector.threatDetected) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.monitorEngine.threatDetector.acknowledgeThreat()
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.monitorEngine.threatDetector.acknowledgeThreat()
                    }
                  )
            )
        }
    }
    
    func getHrvValueString() -> String {
        switch self.monitorEngine.status {
        case MonitorEngineStatus.stopped:
            return "Stopped"
        case MonitorEngineStatus.starting:
            return "Starting"
        case MonitorEngineStatus.active:
            return String(format: "%.1f", self.monitorEngine.hrPoller.latestHrv!.value)
        }
    }
    
    func displayStopStartButton() -> some View {
        switch self.monitorEngine.status {
        case MonitorEngineStatus.starting, MonitorEngineStatus.active:
            return Button(action: { stopMonitor() }) {
                Text("Stop")
            }
        case MonitorEngineStatus.stopped:
            return Button(action: { startMonitor() }) {
                Text("Start")
            }
        }
    }
    
    func stopMonitor() {
        self.monitorEngine.stopMonitoring()
    }
    
    func startMonitor() {
        self.monitorEngine.startMonitoring()
    }
    
    func calculateColor() -> Color {
        if self.monitorEngine.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.monitorEngine.hrPoller.latestHrv?.value {
                if hrv <= DANGER_HRV_THRESHOLD {
                    return Color.red
                }
                else if hrv <= WARNING_HRV_THRESHOLD {
                    return Color.yellow
                }
                // above warning threshold
                else {
                    return Color.green
                }
            }
            else {
                fatalError("ERROR - Heart Rate Poller was active but latestHrv was nil")
            }
        }
        else {
            return Color.gray
        }
    }
}

struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

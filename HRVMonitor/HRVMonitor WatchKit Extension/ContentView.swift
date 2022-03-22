//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit

struct ContentView : View {
    @ObservedObject var hrPoller: HeartRatePoller
    @ObservedObject var threatDetector: ThreatDetector
    @ObservedObject var monitorEngine: MonitorEngine
    
    init () {
        let hrPollerService = HeartRatePoller()
        let threatDetectorService = ThreatDetector()
        
        self.hrPoller = hrPollerService
        self.threatDetector = threatDetectorService
        
        // dependency inject our services into the engine
        self.monitorEngine = MonitorEngine(hrPoller: hrPollerService, threatDetector: threatDetectorService)
    }
    
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
        .alert(isPresented: self.$threatDetector.threatDetected) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.threatDetector.acknowledgeThreat()
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.threatDetector.acknowledgeThreat()
                    }
                  )
            )
        }
    }
    
    func getHrvValueString() -> String {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.stopped:
            return "Stopped"
        case HeartRatePollerStatus.starting:
            return "Starting"
        case HeartRatePollerStatus.active:
            return String(format: "%.1f", self.hrPoller.latestHrv!.value)
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
        if self.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.hrPoller.latestHrv?.value {
                if hrv <= Settings.DangerHRVThreshold {
                    return Color.red
                }
                else if hrv <= Settings.WarningHRVThreshold {
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

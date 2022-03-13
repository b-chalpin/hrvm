//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit
import HealthKit
import UserNotifications

let SAFE_HRV_THRESHOLD: Double = 50.00
let WARNING_HRV_THRESHOLD: Double = 30.00
let DANGER_HRV_THRESHOLD: Double = 20.0
let INIT_CURRENT_HRV = 100.0
// constant for demo purposes only
let RANDOM_HRV_TIME_INTERVAL = 5.0
let notificationFactory = NotificationFactory()

struct ContentView : View {
    // variable to indicate the state of workout mode and heart rate polling
    @State var monitorActive: Bool = true
    @State var monitorTimer : Timer?
    @State var showDangerousHrvAlert: Bool = false
    // hr poller module
    @ObservedObject var hrPoller = HeartRatePoller()
    
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
                displayPauseResumeButton()
            }
        }
        .onAppear {
            startMonitorTimer()
        }
        .alert(isPresented: self.$showDangerousHrvAlert) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {}
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {}
                  )
            )
        }
    }
    
    func getHrvValueString() -> String {
        if !self.monitorActive {
            return "Paused"
        }
        else if self.hrPoller.latestHrv == nil {
            return "Starting"
        }
        else {
            return String(format: "%.1f", self.hrPoller.latestHrv!.value)
        }
    }
    
    func displayPauseResumeButton() -> some View {
        if monitorActive {
            return Button(action: { pauseMonitor() }) {
                Text("Pause")
            }
        }
        else {
            return Button(action: { resumeMonitor() }) {
                Text("Resume")
            }
        }
    }
    
    func pauseMonitor() {
        print("Pausing")
        monitorActive = false
        stopMonitorTimer()
    }
    
    func resumeMonitor() {
        print("Resuming")
        monitorActive = true
        startMonitorTimer()
    }
    
    func startMonitorTimer() {
        // if monitor is active and the timer is not nil, return
        guard (monitorTimer == nil && monitorActive) else { return }
        
        if (monitorActive) {
            monitorTimer = Timer.scheduledTimer(withTimeInterval: RANDOM_HRV_TIME_INTERVAL, repeats: true, block: {_ in
                self.hrPoller.pollHeartRate()

                // this if statment is part of the demo and should be evaluated differently in the future or removed
                if(self.hrPoller.latestHrv != nil && self.hrPoller.latestHrv!.value < DANGER_HRV_THRESHOLD){
                    // plays failure sound and should also activate haptic feedback needs to be deployed and tested
                    WKInterfaceDevice.current().play(.failure)
                    notificationFactory.pushNotification()
                    showDangerousHrvAlert = true
                }
            })
        }
    }
    
    func stopMonitorTimer() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        hrPoller.stopPolling()
    }
    
    func calculateColor() -> Color {
        if (self.hrPoller.latestHrv == nil) {
            return Color.gray
        }

        let hrv = self.hrPoller.latestHrv!.value
        
        if hrv >= SAFE_HRV_THRESHOLD {
            return Color.green
        }
        else if hrv >= WARNING_HRV_THRESHOLD {
            return Color.yellow
        }
        else {
            return Color.red
        }
    }
}

struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

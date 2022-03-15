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

let HRV_MONITOR_INTERVAL_SEC = 5.0

struct ContentView : View {
    // variable to indicate the state of workout mode and heart rate polling
    @State var monitorActive: Bool = true
    @State var monitorTimer: Timer?
    @State var showDangerousHrvAlert: Bool = false
    
    // hr poller module
    @ObservedObject var hrPoller = HeartRatePoller()
    
    // notification factory
    let notificationFactory = NotificationFactory()
    
    // workout manager
    let workoutManager = WorkoutManager()
    
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
        .onAppear {
            startMonitor()
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
            return "Stopped"
        }
        else if self.hrPoller.latestHrv == nil {
            return "Starting"
        }
        else {
            return String(format: "%.1f", self.hrPoller.latestHrv!.value)
        }
    }
    
    func displayStopStartButton() -> some View {
        if monitorActive {
            return Button(action: { stopMonitor() }) {
                Text("Stop")
            }
        }
        else {
            return Button(action: { startMonitor() }) {
                Text("Start")
            }
        }
    }
    
    func stopMonitor() {
        print("Stopping")
        monitorActive = false
        self.workoutManager.endWorkout()
        stopMonitorTimer()
    }
    
    func startMonitor() {
        print("Starting")
        monitorActive = true
        self.workoutManager.startWorkout()
        startMonitorTimer()
        
    }
    
    func startMonitorTimer() {
        // if monitor is active and the timer is not nil, return
        guard (monitorTimer == nil && monitorActive) else { return }
        
        if (monitorActive) {
            monitorTimer = Timer.scheduledTimer(withTimeInterval: HRV_MONITOR_INTERVAL_SEC, repeats: true, block: {_ in
                self.hrPoller.poll()
                
                // demo only
                // self.hrPoller.demo()

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

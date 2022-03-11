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


let SAFE_HRV_THRESHOLD: Double = 70.00
let WARNING_HRV_THRESHOLD: Double = 40.00
let DANGER_HRV_THRESHOLD: Double = 20.0

let INIT_CURRENT_HRV = 100.0

// constant for demo purposes only
let RANDOM_HRV_TIME_INTERVAL = 5.0

struct ContentView : View {
    // variable to indicate the state of workout mode and heart rate polling
    @State var monitorActive: Bool = true
    @State var monitorTimer : Timer?
    
    @State var currentHrv: Double = INIT_CURRENT_HRV
    @State var showDangerousHrvAlert: Bool = false
    
    // getting the current instance of the UNUserNotificationCenter object
    let center = UNUserNotificationCenter.current()

    // live polling module
    let hrPoller = HeartRatePoller()
    
    var body: some View {
        let HRVText = String(format: "%.1f", currentHrv)
        Form {
            Section {
                VStack{
                    Text("HRV").fontWeight(.semibold)
                        .font(.largeTitle)
                        .foregroundColor(calculateColor())
                        .multilineTextAlignment(.center)
                    Text(HRVText).fontWeight(.semibold)
                        .font(.body)
                        .foregroundColor(calculateColor())
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            Section {
                displayPauseResumeButton()
            }
        }
        .onAppear {
            // requesting authorization to notify user
            center.requestAuthorization(options: [.sound, .badge, .alert]){ granted, error in }
            
            startMonitorTimer()
        }
        .alert(isPresented: self.$showDangerousHrvAlert) {
            Alert(title: Text("Check your heart rate"),
                  message: Text("We noticed unusual activity in your Heart Rate Variability."),
                  dismissButton: .default(Text("Dismiss"),
                  action: {
                    showDangerousHrvAlert = false
            }))
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
//                print("Monitor running")
                hrPoller.pollHeartRate()
                
                currentHrv = hrPoller.getLatestHrvValue()

                // this if statment is part of the demo and should be evaluated differently in the future or removed
//                if(currentHrv < 30){
//                    // plays failure sound and should also activate haptic feedback needs to be deployed and tested
//                    WKInterfaceDevice.current().play(.failure)
//
//                    let notificationRequest = constructUserNotification()
//                    deliverUserNotification(request: notificationRequest)
//
//                    showDangerousHrvAlert = true
//                }
            })
        }
    }
    
    func stopMonitorTimer() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    func constructUserNotification() -> UNNotificationRequest{
        let content = UNMutableNotificationContent()
        content.title = "HRV Alert"
        content.body = "We noticed unusual activity in your Heart Rate Variability."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "HRVAlert", content: content, trigger: trigger)
        
        return request
    }
    
    func deliverUserNotification(request: UNNotificationRequest){
        center.add(request) {(error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func calculateColor() -> Color {
        if currentHrv >= SAFE_HRV_THRESHOLD {
            return Color.green
        }
        else if currentHrv >= WARNING_HRV_THRESHOLD {
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

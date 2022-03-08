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
let RANDOM_HRV_TIME_INTERVAL = 1.5

struct ContentView : View {
    @State var currentHrv: Double = INIT_CURRENT_HRV
    @State var showDangerousHrvAlert: Bool = false
    
    // getting the current instance of the UNUserNotificationCenter object
    let center = UNUserNotificationCenter.current()

    // live polling module
    let hrPoller = HeartRatePoller()
    
    // countdownActive for demo purposes
    @State var countdownActive: Bool = false
    
    var body: some View {
        let HRVText = String(format: "%.1f", currentHrv)

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
        // for demo purposes only - will randomly set the currentHrv to a value in [0, 100]
        .onAppear {
            
            // requesting authorization to notify user
            center.requestAuthorization(options: [.sound, .badge, .alert]){granted, error in}
            let notificationRequest = constructUserNotification()
            
            if !countdownActive {
                countdownActive = true
                Timer.scheduledTimer(withTimeInterval: RANDOM_HRV_TIME_INTERVAL, repeats: true, block: {_ in
                    let fixMeLater = hrPoller.getHeartRateWindow()
                    
                    currentHrv = Double.random(in: 1...100)
                    
                    // This if statment is part of the demo and should be evaluated differently in the future or removed
                    if(currentHrv < 30){
                        // plays failure sound and should also activate haptic feedback needs to be deployed and tested
                        WKInterfaceDevice.current().play(.failure)
                        //
                        
                        deliverUserNotification(request: notificationRequest)
                        
                        showDangerousHrvAlert = true
                    }
                })
            }
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

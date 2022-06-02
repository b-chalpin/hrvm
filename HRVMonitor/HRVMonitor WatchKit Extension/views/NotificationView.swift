//
//  NotificationView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Madison R Reese on 2/27/22.
//

import SwiftUI

struct NotificationView: View {
    // we must use singleton here, since the notification controller has no access to EnvironmentObjects
    private var monitorEngine = MonitorEngine.shared
    
    // #task - this view is the same as ManualFeedbackView, need to move to common lib
    var body: some View {
        VStack{
            ScrollView {
                //HRV Label
                Text("Are you Stressed?")
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                Text("We have noticed a dangerous trend in your Heart Rate Variability.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                
                Spacer(minLength: 10.0)
        
                Button(action: {
                    //Add action here - another view/input data
                    self.monitorEngine.acknowledgeThreat(feedback: true, manuallyAcked: false)
                }) {
                        Text("Yes")
                }
                
                Button(action: {
                    //Add action here - another view/input data
                    self.monitorEngine.acknowledgeThreat(feedback: false, manuallyAcked: false)
                }) {
                        Text("No")
                }
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}

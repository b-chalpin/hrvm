//
//  ManualFeedbackView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/1/22.
//

import SwiftUI
import Foundation

struct ManualFeedbackView: View {
    @EnvironmentObject var monitorEngine: MonitorEngine
    
    @Binding var isManualFeedbackViewActive: Bool
    
    // #task - this view is the same as NotificationView, need to move to common lib
    var body: some View {
        VStack {
            if (self.monitorEngine.isPredicting()) { // in order to ack, the app has to be actively predicting
                ScrollView {
                    Text("Are you Stressed?")
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                    Text("We have noticed a dangerous trend in your Heart Rate Variability.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                    
                    Spacer(minLength: 10.0)

                    Button(action: {
                        self.manuallyAcknowledgeThreat(feedback: true)
                    }) {
                            Text("Yes")
                    }
                    
                    Button(action: {
                        self.manuallyAcknowledgeThreat(feedback: false)
                    }) {
                            Text("No")
                    }
                    Button(action: {
                        self.closeManualFeedbackView()
                    }) {
                            Text("Cancel")
                            .foregroundColor(BUTTON_COLOR)
                    }
                }
            }
            else { // we cannot ack until the poller is active
                Text("Manual Feedback Unavailable")
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                Text("Cannot provide feedback unless the HRV monitor is running.")
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                
                Spacer()
                
                Button(action: {
                    self.closeManualFeedbackView()
                }) {
                        Text("Done")
                        .foregroundColor(BUTTON_COLOR)
                }
            }
        }
    }
    
    private func manuallyAcknowledgeThreat(feedback: Bool) {
        // we will tell the monitor engine that we have manually acked this
        self.monitorEngine.acknowledgeThreat(feedback: feedback, manuallyAcked: true)

        self.closeManualFeedbackView()
    }
    
    private func closeManualFeedbackView() {
        self.isManualFeedbackViewActive = false
    }
}

struct ManualFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        ManualFeedbackView(isManualFeedbackViewActive: .constant(true))
    }
}

//
//  NotificationView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Madison R Reese on 2/27/22.
//

import SwiftUI

struct NotificationView: View {
    private var monitorEngine = MonitorEngine.shared
    
    var body: some View {
        VStack{
            //HRV Label
            Text("Are you Stressed?").fontWeight(.semibold)
                .font(.body)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding()
    
            Button(action: {
                //Add action here - another view/input data
                self.monitorEngine.acknowledgeThreat(feedback: true)
            }) {
                    Text("Yes")
            }
            
            Button(action: {
                //Add action here - another view/input data
                self.monitorEngine.acknowledgeThreat(feedback: false)
            }) {
                    Text("No")
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}

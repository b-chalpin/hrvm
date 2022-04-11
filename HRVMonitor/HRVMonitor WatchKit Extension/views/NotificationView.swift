//
//  NotificationView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Madison R Reese on 2/27/22.
//

import SwiftUI

struct NotificationView: View {
    @ObservedObject var threatDetector: ThreatDetector
    
    init () {
        self.threatDetector = ThreatDetector()
    }
    
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
                self.threatDetector.acknowledgeThreat()
            }) {
                    Text("Yes")
            }
            
            Button(action: {
                //Add action here - another view/input data
                self.threatDetector.acknowledgeThreat()
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

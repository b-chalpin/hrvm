//
//  EventLogView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI

struct EventLogView: View {
    let exampleEvents = [
        //self.hrPoller.hrvTimestamp
        Event(id: 5, timeStamp: "12:20:10 APR 2, 2022", hrv: 12.9, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 4, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 3, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 2, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 1, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3])
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("EVENT LOG")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           alignment: .topLeading)
                Text("High Stress Detected")
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           alignment: .topLeading)
                Form {
                    ForEach(self.exampleEvents) { event in
                        NavigationLink(String(event.timeStamp),
                                       destination: EventView(event: event))
                    }
                    .font(.caption2)
                }
            }
        }
    }
}

struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView()
    }
}

//
//  EventView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI
import Charts

struct EventView : View {
    var event: Event
    
    var body : some View{
        VStack {
            Text(event.timeStamp).fontWeight(.bold)
            Text("HRV: " + String(event.hrv))
            Text("Average HRV: " + String(event.averageHR))
            Text("Feedback: " + event.feedback)
            
            Chart(data: event.data)
                .chartStyle(
                    AreaChartStyle(.quadCurve,
                                   fill: LinearGradient(gradient: .init(colors: [Color.red.opacity(0.5), Color.red.opacity(0.05)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom)
                                        .frame(maxHeight: 100)))
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static let exampleEvent: Event = Event(id: 1, timeStamp: "timestamp", hrv: 45.0, averageHR: 78.9, feedback: "Stressed",
                                           data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3])
    
    static var previews: some View {
        EventView(event: exampleEvent)
    }
}

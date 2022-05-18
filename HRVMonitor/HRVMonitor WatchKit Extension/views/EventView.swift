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
            Text(event.timeStamp).fontWeight(.bold).frame(alignment: .top)
            Text("HRV: " + String(event.hrv)).frame(alignment: .top)
            Text("Average HRV: " + String(event.averageHR)).frame(alignment: .top)
            Text("Feedback: " + event.feedback).frame(alignment: .top)
            
            Chart(data: event.data)
                .chartStyle(
                    AreaChartStyle(.quadCurve,
                                   fill: LinearGradient(gradient: .init(colors: [Color.red.opacity(0.5), Color.red.opacity(0.05)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom)
                                    .frame(height: 15, alignment: .bottom)))
            
            NavigationLink(destination: EventLogView()) {
                Text("Done").fontWeight(.semibold)
                .foregroundColor(BUTTON_COLOR)
            }.padding(.horizontal, 40.0)
            .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
            .frame(alignment: .bottom)
            
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

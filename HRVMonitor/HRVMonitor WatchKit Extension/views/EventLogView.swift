//
//  EventLogView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//
import SwiftUI

struct EventLogView: View {
    
    /*
    let exampleEvents = [
        //self.hrPoller.hrvTimestamp
        Event(id: 5, timeStamp: "12:20:10 APR 2, 2022", hrv: 12.9, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 4, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 3, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 2, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
        Event(id: 1, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3])
    ]
     */
    
    @State var events = [ Event(id: 1, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3])    ]
    
    var body: some View {
        NavigationView {
            ZStack{
            VStack {
                Text("EVENTS")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           alignment: .topLeading)
                    .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0)))
                Text("High Stress Detected")
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           alignment: .topLeading)
                 
                /*
                Text("EVENT LOG")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .frame(maxHeight: .infinity,
                           alignment: .topLeading)
                Text("HRV")
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)
                    .padding([.top, .bottom], 5.0)
                 */
                Form{
                    ForEach(self.events) { event in
                        NavigationLink(String(event.timeStamp),
                                       destination: EventView(event: event))
                    }
                    .font(.caption2)
                    Button(action: { fetchEvents() }) {
                        Text("Load More...").fontWeight(.semibold).font(.system(size: 12))
                        .foregroundColor(BUTTON_COLOR)
                    }
                }
            }
        }
        }
        .onAppear {
       // get first set of events
            fetchEvents()
        }
        .onDisappear {
        
        self.events = []
        }
 }
    
    private func fetchEvents() {
            //let newEvents = storageModule.read(event, Settings.EventLogPageSize) // fetch Settings.EventLogPageSize number of events
            let newEvents = [
                Event(id: 5, timeStamp: "12:20:10 APR 3, 2022", hrv: 12.9, averageHR: 15.0, feedback: "False", data: [0.0,0.8,0.7,0.4,0.6,0.4,0.2,0.1,0.2,0.3]),
                ]
        self.events.append(contentsOf: newEvents)// add new events to event list
        }
    }
    
struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView()
    }
}

//
//  EventLogView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI
import Foundation

struct EventLogView: View {
    @EnvironmentObject var storageService: StorageService
    
    @State private var events: [EventItem] = []
    @State private var hasMoreEventPages: Bool = true // if false, we will not display "Load More" button
    
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
                if (self.events.count > 0) {
                    Form {
                        ForEach(self.events) { event in
                            NavigationLink(StringFormatUtils.formatDateToString(input: event.timestamp),
                                           destination: EventView(event: event))
                        }
                        .font(.caption2)
                        
                        if (hasMoreEventPages) {
                            Button(action: { self.getNextPageOfEvents() }) {
                                Text("Load More")
                                    .fontWeight(.semibold)
                                    .foregroundColor(BUTTON_COLOR)
                                
                            }
                        }
                    }
                }
                else {
                    Text("No events recorded.")
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                }
            }
        }
        .onAppear() {
            self.getNextPageOfEvents()
        }
        .onDisappear() {
            self.clearEvents()
        }
    }
    
    private func getNextPageOfEvents() {
        let newEvents = self.storageService.getPageOfEventsForOffset(offset: self.events.count)
        
        if (newEvents.count == 0) {
            self.hasMoreEventPages = false
        }
        else {
            self.events.append(contentsOf: newEvents)
        }
    }
    
    private func clearEvents() {
        self.events = []
        self.hasMoreEventPages = true
    }
}

struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView()
    }
}

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
            self.getPageOfEvents()
        }
        .onDisappear() {
            self.clearEvents()
        }
    }
    
    private func getPageOfEvents() {
        let newEvents = self.storageService.getAllStressEvents()
        self.events.append(contentsOf: newEvents)
    }
    
    private func clearEvents() {
        self.events = []
    }
}

struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView()
    }
}

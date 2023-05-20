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
    @State private var hasMoreEventPages: Bool = true /// If false, we will not display "Load More" button
    
    @State private var isEventViewActiveList: [Bool] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("EVENTS")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("High Stress Detected")
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                if self.events.count > 0 {
                    Form {
                        ForEach(self.events, id: \.self) { event in
                            let isSingleEventViewActive: Binding<Bool> = self.$isEventViewActiveList[self.events.firstIndex(of: event)!]
                            
                            NavigationLink(
                                StringFormatUtils.formatDateToString(input: event.timestamp),
                                isActive: isSingleEventViewActive,
                                destination: { EventView(event: event, isEventViewActive: isSingleEventViewActive) }
                            )
                            .font(.caption2)
                        }
                        
                        if hasMoreEventPages {
                            Button(action: { self.getNextPageOfEvents() }) {
                                Text("Load More")
                                    .fontWeight(.semibold)
                                    .foregroundColor(BUTTON_COLOR)
                            }
                        }
                    }
                } else {
                    Text("No events recorded.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .onAppear {
            self.getNextPageOfEvents()
        }
        .onDisappear {
            self.clearEvents()
        }
    }
    
    private func getNextPageOfEvents() {
        let newEvents = self.storageService.getPageOfEventsForOffset(offset: self.events.count)
        
        if newEvents.isEmpty {
            self.hasMoreEventPages = false
        } else {
            self.isEventViewActiveList.append(contentsOf: Array(repeating: false, count: Settings.StressEventPageSize))
            self.events.append(contentsOf: newEvents)
        }
    }
    
    private func clearEvents() {
        self.events = []
        self.isEventViewActiveList = []
        self.hasMoreEventPages = true
    }
}

struct EventLogView_Previews: PreviewProvider {
    static var previews: some View {
        EventLogView()
    }
}

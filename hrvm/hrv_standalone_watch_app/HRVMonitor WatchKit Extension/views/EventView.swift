//
//  EventView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI
import Charts

/// A view that displays information about an event.
struct EventView: View {
    /// The event item to display.
    public var event: EventItem
    /// Binding indicating whether the event view is active.
    @Binding var isEventViewActive: Bool
    
    var body: some View {
        VStack {
            Text(StringFormatUtils.formatDateToString(input: self.event.timestamp))
                .fontWeight(.bold)
            
            Text("HRV: " + StringFormatUtils.formatDoubleToString(input: self.event.hrv.RMSSD))
            Text("Average HRV: " + StringFormatUtils.formatDoubleToString(input: self.event.hrv.avgHeartRateBPM))
            Text("Stressed: " + String(self.event.isStressed).capitalized)
            
            Spacer()
            
            /// Display the HRV chart
            Chart(data: HrvMapUtils.mapHrvStoreToDoubleArray_Normalized(hrvStore: self.event.hrvStore))
                .chartStyle(
                    AreaChartStyle(.quadCurve, fill:
                                    LinearGradient(gradient: .init(colors: [Color.red.opacity(0.5), Color.red.opacity(0.2)]),
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                        .frame(height: 30, alignment: .top)))
            
            Spacer()
            
            /// Return to EventLogView
            Button(action: {
                self.isEventViewActive = false
            }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundColor(BUTTON_COLOR)
            }
            .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
            .padding(.horizontal, 40.0)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static let dummyHrv = HrvItem(RMSSD: 0.0, timestamp: Date(), deltaHrvValue: 0.0, deltaUnixTimestamp: 0.0, avgHeartRateMS: 0.0, numHeartRateSamples: 0, hrSamples: [], meanRR: 0.0, medianRR: 0.0, pNN50: 0.0)
    static let exampleEvent: EventItem = EventItem(id: UUID(), timestamp: Date(), hrv: dummyHrv, hrvStore: [dummyHrv], isStressed: true, sitStandChange: true)
    
    static var previews: some View {
        EventView(event: exampleEvent, isEventViewActive: .constant(true))
    }
}

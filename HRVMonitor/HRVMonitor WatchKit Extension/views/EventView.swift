//
//  EventView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI
import Charts
import Foundation

struct EventView : View {
    var event: EventItem
    
    var body : some View {
        VStack {
            Text(StringFormatUtils.formatDateToString(input: event.timestamp)).fontWeight(.bold)
            Text("HRV: " + String(event.hrv.value))
//            Text("Average HRV: " + String(event.averageHR))
            Text("Stressed: " + String(event.stressed).capitalized)
            
            Chart(data: HrvMapUtils.mapHrvStoreToDoubleArray(hrvStore: event.hrvStore))
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
    static let dummyHrv = HrvItem(value: 0.0, timestamp: Date(), deltaHrvValue: 0.0, deltaUnixTimestamp: 0.0, avgHeartRateMS: 0.0, numHeartRateSamples: 0, hrSamples: [])
    
    static let exampleEvent: EventItem = EventItem(id: UUID(), timestamp: Date(), hrv: dummyHrv, hrvStore: [dummyHrv], stressed: true)

    static var previews: some View {
        EventView(event: exampleEvent)
    }
}

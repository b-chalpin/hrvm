//
//  StatisticView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/6/22.
//

import SwiftUI
import Charts

struct StatisticView: View {
    @EnvironmentObject var hrPoller: HeartRatePoller
    
    var body: some View {
        VStack {
            HStack {
                Text(getHrvValueString())
                    .fontWeight(.semibold)
                    .font(.system(size: 40))
                    .frame(maxHeight: .infinity,
                           alignment: .topLeading)
                Text("HRV")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .foregroundColor(Color("Color"))
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)
                    .padding([.top, .bottom], 5.0)
            }
            Chart(data: getHrvStoreForChart())
                .chartStyle(
                    AreaChartStyle(.quadCurve, fill:
                                    LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5), Color.white.opacity(0.05)]), startPoint: .top, endPoint: .bottom)
                                    .frame(maxHeight: 25, alignment: .top)
                    )
                )
            HStack {
                // enter graph here
                Text("min\nmax\navg")
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundColor(Color("Color"))
                Text("\(StringFormatUtils.formatDoubleToString(input: self.hrPoller.minHrvValue))\n" +
                     "\(StringFormatUtils.formatDoubleToString(input: self.hrPoller.maxHrvValue))\n" +
                     "\(StringFormatUtils.formatDoubleToString(input: self.hrPoller.avgHrvValue))")
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
            }
            .frame(maxWidth: .infinity,
                   alignment: .bottomLeading)
        }
    }
    
    // TODO: needs to be replaced with long-term data
    func getHrvStoreForChart() -> [Double] {
        // return empty graph array for a hrvstore that is empty or a single item
        if self.hrPoller.hrvStore.count <= 1 {
            return [0.0, 0.0]
        }
        
        let hrvStoreValues = self.hrPoller.hrvStore.map { $0.value }
       
        let min = 0.0 // lowest HRV we can have is 0.0, subtract 10.0 more for padding
        let max = hrvStoreValues.max()! + 10.0 // pad our upper bound for normalization

        return hrvStoreValues.map { ($0 - min) / (max - min) }
    }
    
    func getHrvValueString() -> String {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.stopped, HeartRatePollerStatus.starting:
            return "0.0"
        case HeartRatePollerStatus.active:
            return StringFormatUtils.formatDoubleToString(input: self.hrPoller.latestHrv!.value)
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}

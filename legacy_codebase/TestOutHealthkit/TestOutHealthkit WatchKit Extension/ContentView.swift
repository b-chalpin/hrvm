//
//  ContentView.swift
//  TestOutHealthkit WatchKit Extension
//
//  Created by EWU Team5 on 9/27/21.
//

import SwiftUI
import HealthKit


struct ContentView: View {
    
    private var healthStore: HealthStore?
    @State private var heartRateVariabilities : [HeartRateVariability] = [HeartRateVariability]()
    
    //@State private var timer = Timer()
    @State private var heartRates : [String]!
    @State private var indexCounter = 0
    
    init() {
        healthStore = HealthStore()
    }
    
    private func updateUIFromStatistics(statisticsCollection: HKStatisticsCollection) {
        
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let endDate = Date()
        
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in

            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            
            let hrv = HeartRateVariability(count: Int(count ?? 0), date: statistics.startDate)
            heartRateVariabilities.append(contentsOf: [hrv])
        }
    }
    
    var body: some View {
        
        NavigationView {
        
            List(heartRateVariabilities, id: \.id) { hrv in
                VStack(alignment: .leading) {
                    Text("\(hrv.count)")
                    Text(hrv.date, style: .date)
                        .opacity(0.5)
                }
            }
            .navigationTitle("Heart Rate Variability Yo!")
        }
        .onAppear {
//            if let healthStore = healthStore {
//                healthStore.requestAuthorization { success in
//                    if success {
//                        healthStore.calculateSteps { statisticsCollection in
//                            if let statisticsCollection = statisticsCollection {
//                                // Update the UI
//                                updateUIFromStatistics(statisticsCollection: statisticsCollection)
//                            }
//                        }
//                    }
//                }
//            }
            
            
            //
            // Load text file with mock data and
            // kick off a timer to read it every one second
            //
            loadUpTextFileWithHeartRates()
        }
    }
    
    private func loadUpTextFileWithHeartRates() {
        // Load 'er up!
        if let path = Bundle.main.path(forResource: "mock_data", ofType: "txt") {
            let contents = try! String(contentsOfFile: path, encoding: .utf8)
            self.heartRates = contents.components(separatedBy: .newlines)
        }
        
        // Timer that runs once a second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in      // NOTE: this used to assign to self.timer but a weird, unexplained error kept popping up for some apple amazing reason.
            readNextHeartRate()
        })
    }
    
    private func readNextHeartRate() {
        print(self.heartRates[indexCounter])
        self.indexCounter+=1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import SwiftUI
import SwiftUICharts
import UIKit

struct ContentView: View {
    @State private var hrvProcessor : HRVProcessor?
    @State private var hrvLoader : HRVParser?
    @State private var text : String = ""
    @State private var hrvOverTime : [Double] = []
    
    @State private var showUnusualHRVWarning : Bool = false
    @State private var dontshowHRVWarningUntilNormal : Bool = false
    @State private var initializedTimer : Bool = false
    
    var body: some View {
        VStack {
            // Line Chart
            LineChartView(data: hrvOverTime, title: "HRV", style: ChartStyle(backgroundColor: .white, accentColor: .white, gradientColor: .init(start: .blue, end: .red), textColor: .white, legendTextColor: .gray, dropShadowColor: .black), form: ChartForm.extraLarge, rateValue: 0)
                // .frame(width: 180, height: 500, alignment: .center)
            .onAppear
            {
                if !initializedTimer {          // NOTE: every time the alert is dismissed (line 43), this onAppear event runs again, so you need this lock here. Or if there's an init() function you could use or something!!! I'm just following the tutorials, and we didn't get too much of a chance to look at the tutorials :(
                    initializedTimer = true
                    
                    hrvProcessor = HRVProcessor()
                    hrvLoader = HRVParser(fname: "mock_data")
                    
                    // Timer that runs once a second
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in      // NOTE: this used to assign to self.timer but a weird, unexplained error kept popping up for some apple amazing reason.
                        readNextHeartRate()
                    })
                }
            }
            
            Text(text + "ms")       // Weirdly this isn't showing up in the actual UI. Must be out of view...
            .alert(isPresented: $showUnusualHRVWarning)
            {
                Alert(title: Text("Check your heart rate"), message: Text("We noticed unusual activity in your heart rate."), dismissButton: .default(Text("Dismiss"), action: {
                    dontshowHRVWarningUntilNormal = true
                    print("\t\tJOJO")
                }))
            }
            
        }
    }
    
    private func readNextHeartRate() {
        hrvProcessor!.add(entry: hrvLoader!.readNextEntry()!)
        
        let hrv = hrvProcessor!.calcCurrentHRV()
        if !hrv.isNaN {
            text = String(format: "%.2f", hrv)
            hrvOverTime.append(Double(text)!)
            
            // Check if hrvProcessor found an unusual HRV
            if dontshowHRVWarningUntilNormal {
                print("\t\tUhhuh")
                if !hrvProcessor!.outlierData {
                    dontshowHRVWarningUntilNormal = false
                    print("\t\t\tYa good man")
                }
            }
            else {
                if !showUnusualHRVWarning && hrvProcessor!.outlierData {
                    showUnusualHRVWarning = true
                    print("\t\tVERY UnUSUAL")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

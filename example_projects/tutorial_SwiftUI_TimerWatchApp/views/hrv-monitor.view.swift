//
//  hrv-monitor.view.swift
//  tutorial_SwiftUI_TimerWatchApp WatchKit Extension
//
//  Created by bchalpin on 2/2/22.
//

import SwiftUI

struct HrvMonitorConstants {
    static let INIT_HRV_VALUE: Double = 156.44
    static let TIME_INTERVAL: Double = 0.5
    static let REPEATS: Bool = true
    static let HRV_STEP_SIZE: Double = 15.37
}

struct HrvMonitorView: View {
    @State var hrvValue: Double = HrvMonitorConstants.INIT_HRV_VALUE
    @State var showDangerousHrvAlert: Bool = false
    @State var countdownActive: Bool = false
    
    func resetHrvValue() {
        self.hrvValue = HrvMonitorConstants.INIT_HRV_VALUE
    }
    
    var body: some View {
        VStack {
            Text("HRV")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(String(format: "%.2f", self.hrvValue))")
        }
        .onAppear {
            if !self.countdownActive {
                self.countdownActive = true
                
                Timer.scheduledTimer(withTimeInterval: HrvMonitorConstants.TIME_INTERVAL, repeats: HrvMonitorConstants.REPEATS, block: {_ in
                    
                    self.hrvValue -= HrvMonitorConstants.HRV_STEP_SIZE
                    
                    if self.hrvValue <= 0 {
                        self.showDangerousHrvAlert = true
                    }
                })
            }
        }
        // when self.showDangerousHrvAlert is true, this alert will be shown
        .alert(isPresented: self.$showDangerousHrvAlert) {
            Alert(title: Text("Check your heart rate"),
                  message: Text("We noticed unusual activity in your Heart Rate Variability."),
                  dismissButton: .default(Text("Dismiss"),
                  action: {
                    self.showDangerousHrvAlert = false
                    self.resetHrvValue()
                  }))
        }
    }
}

struct HrvMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HrvMonitorView()
        }
    }
}

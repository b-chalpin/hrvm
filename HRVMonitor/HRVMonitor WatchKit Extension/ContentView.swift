//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI

let SAFE_HRV_THRESHOLD: Double = 70.00
let WARNING_HRV_THRESHOLD: Double = 40.00
let DANGER_HRV_THRESHOLD: Double = 20.0

let INIT_CURRENT_HRV = 100.0

// constant for demo purposes only
let RANDOM_HRV_TIME_INTERVAL = 1.5

struct ContentView : View {
    @State var currentHrv: Double = INIT_CURRENT_HRV
    
    // countdownActive for demo purposes
    @State var countdownActive: Bool = false
    
    var body: some View {
        let HRVText = String(format: "%.1f", currentHrv)

        VStack{
            Text("HRV").fontWeight(.semibold)
                .font(.largeTitle)
                .foregroundColor(calculateColor())
                .multilineTextAlignment(.center)
            Text(HRVText).fontWeight(.semibold)
                .font(.body)
                .foregroundColor(calculateColor())
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        // for demo purposes only - will randomly set the currentHrv to a value in [0, 100]
        .onAppear {
            if !countdownActive {
                countdownActive = true
                Timer.scheduledTimer(withTimeInterval: RANDOM_HRV_TIME_INTERVAL, repeats: true, block: {_ in
                    currentHrv = Double.random(in: 1...100)
                })
            }
        }
    }
    
    func calculateColor() -> Color {
        if currentHrv >= SAFE_HRV_THRESHOLD {
            return Color.green
        }
        else if currentHrv >= WARNING_HRV_THRESHOLD {
            return Color.yellow
        }
        else {
            return Color.red
        }
    }
}

struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit
import Charts

// TODO: IMPLIMENT GRAPH & GET RID OF LARGE BUTTON BACKGROUND

// TODO: move these to config
let SAFE_HRV_THRESHOLD: Double = 50.00
let WARNING_HRV_THRESHOLD: Double = 30.00
let DANGER_HRV_THRESHOLD: Double = 20.0
let HRV_MONITOR_INTERVAL_SEC = 3.0

struct ContentView : View {
    @State private var isLoading = false
    @ObservedObject var monitorEngine = MonitorEngine()
    
    var body: some View {
        Section {
            TabView{
                //Page 1
                ZStack{
                    
                    Chart(data: [0.9,0.9,0.6,0.7,0.4,0.5,0.1])
                        .chartStyle(
                            AreaChartStyle(.quadCurve, fill:
                                            LinearGradient(gradient: .init(colors: [calculateColor().opacity(0.5), calculateColor().opacity(0.05)]), startPoint: .top, endPoint: .bottom)
                                        .offset(x: 0, y: -52)
                            )
                        )
            
                    
                    calculateHeart()
                        .resizable()
                        .opacity(0.5)
                        .frame(width: 25,
                               height: 22,
                            alignment: .topTrailing)
                        .offset(x: 75, y: -70)
                    VStack(spacing: 10){
                        Text(getHrvValueString())
                            .fontWeight(.semibold)
                            .font(.system(size: 50))
                            .foregroundColor(calculateColor().opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.top, 30.0)
                            .padding(.bottom, 0.0)
                        Text("HRV")
                            .fontWeight(.semibold)
                            .foregroundColor(calculateColor().opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5.0)
                        
                        displayStopStartButton()
                
                    }
                }
                //Page2
                VStack {
                    HStack{
                        Text(getHrvValueString())
                            .fontWeight(.semibold)
                            .font(.system(size: 40))
                            .foregroundColor(Color("Color"))
                            .frame(maxHeight: .infinity,
                                   alignment: .topLeading)
                        Text("HRV")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .foregroundColor(Color("Color"))
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity,
                                   alignment: .topLeading)
                            .padding(.top, 10.0)
                    }
                    //enter graph here
                    Text("minimum" + "\nmaximum" + "\naverage")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundColor(Color("Color"))
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .bottomLeading)
                    
                }
                //Page 3
                HStack{
                    Text("Settings")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundColor(Color("Color"))
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                }
            }
        }
        
        .alert(isPresented: self.$monitorEngine.threatDetector.threatDetected) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.monitorEngine.threatDetector.acknowledgeThreat()
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.monitorEngine.threatDetector.acknowledgeThreat()
                    }
                  )
            )
        }
    }
    
    func getHrvValueString() -> String {
        switch self.monitorEngine.status {
        case MonitorEngineStatus.stopped:
            return "0.0"
        case MonitorEngineStatus.starting:
            return "0.0"
        case MonitorEngineStatus.active:
            return String(format: "%.1f", self.monitorEngine.hrPoller.latestHrv!.value)
        }
    }
    
    func displayStopStartButton() -> some View {
        switch self.monitorEngine.status {
        case MonitorEngineStatus.starting:
            return AnyView(
                Button(action: { stopMonitor() }) {
                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 4)
                        .frame(width: 20, height:20)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.default.repeatForever(autoreverses:false))
                        .onAppear() {
                            self.isLoading = true
                        }
                }
                    .padding(.horizontal, 40.0)
                    .buttonStyle(BorderedButtonStyle(tint:Color.gray.opacity(0.0)))
            )
        case MonitorEngineStatus.active:
            return AnyView(Button(action: { stopMonitor() }) {
                Text("STOP")
                    .fontWeight(.semibold)
                    .foregroundColor(calculateColor().opacity(0.5))
            }
                .padding(.horizontal, 40.0)
                .buttonStyle(BorderedButtonStyle(tint:Color.gray.opacity(0.4)))
            )
        case MonitorEngineStatus.stopped:
            return AnyView(Button(action: { startMonitor() })
                {
                Text("START")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue.opacity(0.5))
            }
                .padding(.horizontal, 40.0)
                .buttonStyle(BorderedButtonStyle(tint:Color.gray.opacity(0.4)))
               )
        }
    }

    
    func stopMonitor() {
        self.monitorEngine.stopMonitoring()
    }
    
    func startMonitor() {
        self.monitorEngine.startMonitoring()
    }
    
    func calculateColor() -> Color {
        if self.monitorEngine.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.monitorEngine.hrPoller.latestHrv?.value {
                if hrv <= DANGER_HRV_THRESHOLD {
                    return Color.red
                }
                else if hrv <= WARNING_HRV_THRESHOLD {
                    return Color.yellow
                }
                // above warning threshold
                else {
                    return Color.green
                }
            }
            else {
                fatalError("ERROR - Heart Rate Poller was active but latestHrv was nil")
            }
        }
        else {
            return Color("Color")
        }
    }
    
    func calculateHeart() -> Image {
        if self.monitorEngine.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.monitorEngine.hrPoller.latestHrv?.value {
                if hrv <= DANGER_HRV_THRESHOLD {
                    return Image("redHeart")
                }
                else if hrv <= WARNING_HRV_THRESHOLD {
                    return Image("yellowHeart")
                }
                // above warning threshold
                else {
                    return Image("greenHeart")
                }
            }
            else {
                fatalError("ERROR - Heart Rate Poller was active but latestHrv was nil")
            }
        }
        else {
            return Image("grayHeart")
        }
    }
}



struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}

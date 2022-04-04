//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit

struct ContentView : View {
    @ObservedObject var hrPoller: HeartRatePoller
    @ObservedObject var threatDetector: ThreatDetector
    @ObservedObject var monitorEngine: MonitorEngine
    
    init () {
        let hrPollerService = HeartRatePoller()
        let threatDetectorService = ThreatDetector()
        
        self.hrPoller = hrPollerService
        self.threatDetector = threatDetectorService
        
        // dependency inject our services into the engine
        self.monitorEngine = MonitorEngine(hrPoller: hrPollerService, threatDetector: threatDetectorService)
    }
    
    var body: some View {
        Section {
            TabView{
                //Page 1
                ZStack{
                    calculateHeart()
                        .resizable()
                        .frame(width: 25,
                               height: 22,
                            alignment: .topTrailing)
                        .offset(x: 75, y: -70)
                    VStack(spacing: 10){
                        Text(getHrvValueString())
                            .fontWeight(.semibold)
                            .font(.system(size: 50))
                            .foregroundColor(calculateColor())
                            .multilineTextAlignment(.center)
                            .padding(.top, 30.0)
                            .padding(.bottom, 0.0)
                        Text("HRV")
                            .fontWeight(.semibold)
                            .foregroundColor(calculateColor())
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10.0)
                       
                        
                        displayStopStartButton()
                           .padding(.bottom, 5.0)
                
                    }
                    .padding()
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
                            .padding(.top, 18.0)
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
        .alert(isPresented: self.$threatDetector.threatDetected) {
            Alert(
                title: Text("Are you stressed?"),
                primaryButton: .default(
                    Text("No"),
                    action: {
                        self.threatDetector.acknowledgeThreat()
                    }
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: {
                        self.threatDetector.acknowledgeThreat()
                    }
                  )
            )
        }
    }
    
    func getHrvValueString() -> String {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.stopped:
            return "Stopped"
        case HeartRatePollerStatus.starting:
            return "Starting"
        case HeartRatePollerStatus.active:
            return String(format: "%.1f", self.hrPoller.latestHrv!.value)
        }
    }
    
    func displayStopStartButton() -> some View {
        switch self.monitorEngine.status {
        case MonitorEngineStatus.starting:
            return AnyView(
                Button(action: { stopMonitor() }) {
                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(Color.blue, lineWidth: 4)
                        .frame(width: 20, height:20)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.default.repeatForever(autoreverses:false))
                        .onAppear() {
                            self.isLoading = true
                        }
                })
        case MonitorEngineStatus.active:
            return AnyView(Button(action: { stopMonitor() }) {
                Text("STOP")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue)
            })
        case MonitorEngineStatus.stopped:
            return AnyView(Button(action: { startMonitor() })
                {
                Text("START")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue)
            }.background(Color.black))
        }
    }

    
    func stopMonitor() {
        self.monitorEngine.stopMonitoring()
    }
    
    func startMonitor() {
        self.monitorEngine.startMonitoring()
    }
    
    func calculateColor() -> Color {
        if self.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.hrPoller.latestHrv?.value {
                if hrv <= Settings.DangerHRVThreshold {
                    return Color.red
                }
                else if hrv <= Settings.WarningHRVThreshold {
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

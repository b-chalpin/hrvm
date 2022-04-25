//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 2/28/22.
//

import SwiftUI
import WatchKit
import Charts

struct Event: Identifiable {
    var id: Double
    //var hrv: Double
    var timeStamp: String
    //var feedback: String
    var hrv: Double
    var averageHR: Double
    var feedback: String
}

//var before

struct ContentView : View {
    @State private var isLoading = false
    @State private var isActive : Bool = false
    @State private var selectedSex = 1
    @State private var selectedAge = 25.0
    @State private var isEditing = false
    
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
    let events = [
        //self.hrPoller.hrvTimestamp
        Event(id: 5, timeStamp: "12:20:10 APR 2, 2022", hrv: 12.9, averageHR: 15.0, feedback: "False"),
        Event(id: 4, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False"),
        Event(id: 3, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False"),
        Event(id: 2, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False"),
        Event(id: 1, timeStamp: "12:20:10 APR 2, 2022", hrv: 18.0, averageHR: 15.0, feedback: "False")
    ]
    
    var body: some View {
    
        Section {
            TabView{
                // Page 1
                // dynamic HRV graph
                //List(events, children: \.subDetails) { item in
                NavigationView{
                ZStack{
                    VStack {
                        Chart(data: getHrvStoreForChart())
                            .chartStyle(
                                AreaChartStyle(.quadCurve, fill:
                                                LinearGradient(gradient: .init(colors: [calculateMoodColor().opacity(0.5), calculateMoodColor().opacity(0.05)]), startPoint: .top, endPoint: .bottom)
                                                .frame(maxHeight: 100)
                                )
                            )
                            .padding(.top, 5.0)
                        Spacer()
                    }
                    
                    // heart icon
                    VStack {
                        HStack {
                            NavigationLink(destination: SettingsView()) {
                                Image("settingsIcon").resizable()
                                    .opacity(0.6)
                                    .frame(width: 25, height: 25,alignment: .topLeading)
                            }.buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.0))).frame(maxWidth: 50, alignment: .topLeading)
                            Image("settingsIcon").resizable()
                            .opacity(0.0)
                            .frame(width: .infinity,
                                   height: 2,
                                   alignment: .top)
                            calculateMoodHeart()
                                .resizable()
                                .opacity(0.8)
                                .frame(width: 25,
                                       height: 22,
                                       alignment: .topTrailing)
                                .padding(.trailing, 10.0)

                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 10){
                        Spacer()
                        Text(getHrvValueString())
                            .fontWeight(.semibold)
                            .font(.system(size: 50))
                            .foregroundColor(calculateMoodColor())
                            .multilineTextAlignment(.center)
                        Text("HRV")
                            .fontWeight(.semibold)
                            .foregroundColor(calculateMoodColor())
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5.0)
                        
                        calculateStopStartButton()
                            .padding(.horizontal, 40.0)
                            .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
                    }
                }
                }
                // Page2
                VStack {
                    HStack{
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
                                            LinearGradient(gradient: .init(colors: [calculateMoodColor().opacity(0.5), calculateMoodColor().opacity(0.05)]), startPoint: .top, endPoint: .bottom)
                                            .frame(maxHeight: 25, alignment: .top)
                            )
                        )
                    HStack {
                        // enter graph here
                        Text("min\nmax\navg")
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundColor(Color("Color"))
                        Text("\(formatDoubleToString(input: self.hrPoller.minHrvValue))\n" +
                             "\(formatDoubleToString(input: self.hrPoller.maxHrvValue))\n" +
                             "\(formatDoubleToString(input: self.hrPoller.avgHrvValue))")
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity,
                           alignment: .bottomLeading)
                }
                // Page 3
                VStack{
                    Text("EVENT LOG")
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity,
                               alignment: .topLeading)
                    Text("High Stress Detected")
                        .fontWeight(.semibold)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity,
                               alignment: .topLeading)
                NavigationView{
                    Form {
                        ForEach(self.events) { event in
                            NavigationLink(String(event.timeStamp),
                                destination:
                            VStack{
                                Text(event.timeStamp).fontWeight(.bold)
                                Text("HRV: " + String(event.hrv))
                                Text("Average HRV: " + String(event.averageHR))
                                Text("Feedback: " + event.feedback)
                            })
                            }.font(.caption2)
                        }
                    }.frame( alignment: .top)
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
    
    struct SettingsView : View {
        var sex = ["Female", "Male"]
        @State private var selectedSex = 1
        @State private var selectedAge = 25.0
        @State private var isEditing = false
        
        var body : some View{
            VStack{
                Text("Settings")
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity,
                           alignment: .topLeading)
            Form{
                HStack{
                    Text("Sex:").fontWeight(.semibold)
                        //.font(.system(size: 16))
                        .foregroundColor(Color.white)
                    Picker("",selection: $selectedSex){
                        Text("Male").tag(1)
                        Text("Female").tag(2)
                    }.font(.system(size: 16))
                        .foregroundColor(Color.white)
                }
                HStack{
                    Text("Age: \(selectedAge, specifier: "%g")")
                    VStack{
                        Slider(value: $selectedAge,
                           in: 0...100, step: 1,
                           onEditingChanged: {
                        editing in isEditing = editing
                        })
                    }
                }
                
                /*
                HStack{
                    Text("Age:").fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                    Picker("",selection: $selectedAge){
                        ForEach(1..<100) {
                            Text("\($0)").tag("\($0)")
                        }
                    }.frame(maxWidth: 100)
                 
                }
                
                //Text("Other Settings...").frame(alignment: .topLeading).font(.system(size: 12))
            }.frame(alignment: .top)
                 */
            }
        }
        }
    }
    
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
    
    func formatDoubleToString(input: Double) -> String {
        return String(format: "%.1f", input)
    }
    
    func getHrvValueString() -> String {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.stopped, HeartRatePollerStatus.starting:
            return "0.0"
        case HeartRatePollerStatus.active:
            return formatDoubleToString(input: self.hrPoller.latestHrv!.value)
        }
    }
    
    func calculateStopStartButton() -> some View {
        // common style between buttons
        let buttonColor = Color.blue.opacity(0.8)
        
        switch self.hrPoller.status {
            case HeartRatePollerStatus.starting:
                return AnyView(
                    Button(action: { stopMonitor() }) {
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(buttonColor, lineWidth: 4)
                            .frame(width: 20, height: 20)
                            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                            .animation(Animation.default.repeatForever(autoreverses: false))
                            .onAppear() {
                                self.isLoading = true
                            }
                    }
                )
            case HeartRatePollerStatus.active:
                return AnyView(Button(action: { stopMonitor() }) {
                    Text("STOP")
                        .fontWeight(.semibold)
                        .foregroundColor(buttonColor)
                        .onAppear() {
                            self.isLoading = false // reset the isLoading flag
                        }
                }
                )
            case HeartRatePollerStatus.stopped:
                return AnyView(Button(action: { startMonitor() }) {
                    Text("START")
                        .fontWeight(.semibold)
                        .foregroundColor(buttonColor)
                        .onAppear() {
                            self.isLoading = false // reset the isLoading flag
                        }
                }
                )
        }
    }
    
    func stopMonitor() {
        self.monitorEngine.stopMonitoring()
    }
    
    func startMonitor() {
        self.monitorEngine.startMonitoring()
    }
    
    func calculateMoodColor() -> Color {
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
    
    func calculateMoodHeart() -> Image {
        if self.hrPoller.isActive() {
            // check for the unexpected case where
            if let hrv = self.hrPoller.latestHrv?.value {
                if hrv <= Settings.DangerHRVThreshold {
                    return Image("redHeart")
                }
                else if hrv <= Settings.WarningHRVThreshold {
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

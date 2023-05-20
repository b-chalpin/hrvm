//
//  MonitorView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/6/22.
//

import SwiftUI
import Charts

/// A view that displays the heart rate monitor and allows user interaction with settings.
struct MonitorView: View {
    @EnvironmentObject var hrPoller: HeartRatePoller
    @EnvironmentObject var monitorEngine: MonitorEngine
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isLoading = false // Used for scroll wheel animation
    
    @State var isEventViewActive: Bool = false // Used for the navigation link to settings
    @State var isManualFeedbackViewActive: Bool = false // Used for the navigation link to settings
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Chart(data: HrvMapUtils.mapHrvStoreToDoubleArray_Normalized(hrvStore: self.hrPoller.hrvStore))
                        .chartStyle(
                            AreaChartStyle(.quadCurve, fill:
                                            LinearGradient(gradient: .init(colors: [calculateMoodColor().opacity(0.5), calculateMoodColor().opacity(0.05)]),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                                .frame(maxHeight: 100)))
                        .padding(.top, 5.0)
                    Spacer()
                }
                VStack {
                    HStack {
                        // Settings icon which links to SettingsView
                        NavigationLink(isActive: self.$isEventViewActive, destination: { SettingsView(isSettingsViewActive: self.$isEventViewActive) }) {
                            Image("settingsIcon")
                                .resizable()
                                .opacity(0.9)
                                .frame(width: 25,
                                        height: 25,
                                        alignment: .topLeading)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.0)))
                        .frame(maxWidth: 50, alignment: .topLeading)
                        
                        Spacer()
                        
                        // Manual feedback icon which links to ManualFeedbackView
                        NavigationLink(isActive: self.$isManualFeedbackViewActive, destination: { ManualFeedbackView(isManualFeedbackViewActive: self.$isManualFeedbackViewActive) }) {
                            // Heart icon
                            Image(calculateMoodHeartImageName())
                                .resizable()
                                .frame(width: 25,
                                        height: 22,
                                        alignment: .topTrailing)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.0)))
                        .frame(maxWidth: 50, alignment: .topTrailing)
                    }
                    Spacer()
                }
                VStack(spacing: 10) {
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
        .onChange(of: scenePhase) { phase in
            self.monitorEngine.updateAppState(phase: phase)
        }
    }
    
    /// Returns the formatted HRV value as a string.
    func getHrvValueString() -> String {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.stopped, HeartRatePollerStatus.starting:
            return "0.0"
        case HeartRatePollerStatus.active:
            return StringFormatUtils.formatDoubleToString(input: self.hrPoller.latestHrv!.RMSSD)
        }
    }
    
    /// Calculates the appearance and functionality of the stop/start button based on the heart rate poller status.
    func calculateStopStartButton() -> some View {
        switch self.hrPoller.status {
        case HeartRatePollerStatus.starting:
            return AnyView(
                Button(action: { stopMonitor() })
                {
                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(BUTTON_COLOR, lineWidth: 4)
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.default.repeatForever(autoreverses: false))
                        .onAppear() { self.isLoading = true }
                }
            )
            
        case HeartRatePollerStatus.active:
            return AnyView(
                Button(action: { stopMonitor() }) {
                    Text("STOP")
                        .fontWeight(.semibold)
                        .foregroundColor(BUTTON_COLOR)
                        .onAppear() { self.isLoading = false } // Reset the isLoading flag
                }
            )
            
        case HeartRatePollerStatus.stopped:
            return AnyView(
                Button(action: { startMonitor() }) {
                    Text("START")
                        .fontWeight(.semibold)
                        .foregroundColor(BUTTON_COLOR)
                        .onAppear() { self.isLoading = false } // Reset the isLoading flag
                }
            )
        }
    }
    
    /// Stops the heart rate monitor.
    func stopMonitor() {
        self.monitorEngine.stopMonitoring()
    }
    
    /// Starts the heart rate monitor.
    func startMonitor() {
        self.monitorEngine.startMonitoring()
    }
    
    /// Calculates the color for the mood based on the heart rate variability (HRV) value.
    func calculateMoodColor() -> Color {
        if self.hrPoller.isActive() {
            // Check for the unexpected case where latestHrv is nil
            if let hrv = self.hrPoller.latestHrv?.RMSSD {
                if hrv <= Settings.MoodDangerHRVThreshold {
                    return Color.red
                } else if hrv <= Settings.MoodWarningHRVThreshold {
                    return Color.yellow
                } else {
                    return Color.green
                }
            } else {
                fatalError("ERROR - Heart Rate Poller was active but latestHrv was nil")
            }
        } else {
            return Color("Color")
        }
    }
    
    /// Calculates the heart icon image name based on the heart rate variability (HRV) value.
    func calculateMoodHeartImageName() -> String {
        if self.hrPoller.isActive() {
            // Check for the unexpected case where latestHrv is nil
            if let hrv = self.hrPoller.latestHrv?.RMSSD {
                if hrv <= Settings.MoodDangerHRVThreshold {
                    return "redHeart"
                } else if hrv <= Settings.MoodWarningHRVThreshold {
                    return "yellowHeart"
                } else {
                    return "greenHeart"
                }
            } else {
                fatalError("ERROR - Heart Rate Poller was active but latestHrv was nil")
            }
        } else {
            return "grayHeart"
        }
    }
}

struct MonitorView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorView()
    }
}

//
//  ContentView.swift
//  HRVMonitor
//
//  Created by Nick Adams on 6/2/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: PhoneExportSession
    
    @State private var isReachable = "NO"
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                }
                Spacer()
            }
            .background(Color.init(.systemGray5))
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                    }
                    .foregroundColor(selectedTab == 0 ? Color.accentColor : Color.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 1
                    }) {
                        VStack {
                            Image(systemName: "heart.fill")
                            Text("Stress Data")
                        }
                    }
                    .foregroundColor(selectedTab == 1 ? Color.accentColor : Color.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 2
                    }) {
                        VStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                    .foregroundColor(selectedTab == 2 ? Color.accentColor : Color.gray)
                    
                }
            }
            .overlay(
                Group {
                    if selectedTab == 0 {
                        ExportView()
                    } else if selectedTab == 1 {
                        StressDataView()
                    } else {
                        SettingsView()
                    }
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

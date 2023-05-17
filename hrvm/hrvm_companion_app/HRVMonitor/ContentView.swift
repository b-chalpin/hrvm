//
//  ContentView.swift
//  HRVMonitor
//
//  Created by Nick Adams on 6/2/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: PhoneExportSession
    
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
                }
            }
            .overlay(
                Group {
                    if selectedTab == 0 {
                        ExportView()
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
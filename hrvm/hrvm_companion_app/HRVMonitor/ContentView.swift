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
    
    var body: some View {
        NavigationView {
            VStack {
                Text("HRV Export")
                    .font(.title)
                HStack {
                    Button(action: {
                        let updateIsReachable: String
                        if self.session.session == nil {
                            updateIsReachable = "NO"
                        }
                        else {
                            updateIsReachable = self.session.session!.isReachable ? "YES": "NO"
                        }
                        
                        self.isReachable = updateIsReachable
                    }) {
                        Text("Refresh")
                    }
                    .padding(.leading, 16.0)
                    
                    Spacer()
                    
                    Text("Export Session Active:")
                        .font(.headline)
                        .padding()
                    Text(self.isReachable)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                }
                
                Text("In order for your iPhone to receive export from the Watch, this app must be open.")
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .background(Color.init(.systemGray5))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

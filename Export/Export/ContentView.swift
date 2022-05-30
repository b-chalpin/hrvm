//
//  ContentView.swift
//  Export
//
//  Created by Jared adams on 20/05/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var watch = WatchConnectivityManager()
    @State private var isReachable = "NO"
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        self.isReachable = self.watch.session.isReachable ? "YES": "NO"
                    }) {
                        Text("Check")
                    }
                    .padding(.leading, 16.0)
                    Spacer()
                    Text("isReachable")
                        .font(.headline)
                        .padding()
                    Text(self.isReachable)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                }
                .background(Color.init(.systemGray5))
                List {

                }
                .listStyle(PlainListStyle())
                Spacer()
            }
            .navigationTitle("Receiver")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

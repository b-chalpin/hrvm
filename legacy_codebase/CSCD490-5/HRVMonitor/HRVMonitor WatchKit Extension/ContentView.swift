//
//  ContentView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .padding()
            .onAppear
        {
            let prov = HRVProcessor()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

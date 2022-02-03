//
//  ContentView.swift
//  tutorial_SwiftUI_TimerWatchApp WatchKit Extension
//
//  Created by bchalpin on 2/1/22.
//

import SwiftUI

struct MainView: View {
    @State private var secondScreenShown = false
    @State private var timerVal = 1
    
    var body: some View {
        VStack {
            Text("Timer for \(timerVal) seconds")
                .fontWeight(.bold)
            Picker(selection: $timerVal, label: Text("")) {
                Text("1").tag(1)
                Text("5").tag(5)
                Text("10").tag(10)
                Text("15").tag(15)
                Text("20").tag(20)
            }
            
            NavigationLink(destination:
                            CountdownView(secondScreenShown: $secondScreenShown, timeRemaining: timerVal),
                            isActive: $secondScreenShown,
                            label: { Text("Go") })
        }
    }
}

// test the for loop method
func testForLoop() {
    var pickValues: [Int] = [1, 5, 15, 20]
    
    pickValues.removeFirst(2)
    
    for pickVal in [1, 5, 15, 20] {
        print(pickVal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}

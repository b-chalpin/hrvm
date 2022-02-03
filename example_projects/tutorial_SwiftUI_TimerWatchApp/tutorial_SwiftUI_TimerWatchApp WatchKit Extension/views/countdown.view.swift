//
//  File.swift
//  tutorial_SwiftUI_TimerWatchApp WatchKit Extension
//
//  Created by bchalpin on 2/2/22.
//

import SwiftUI

struct CountdownView: View {
    @Binding var secondScreenShown: Bool
    @State var timeRemaining: Int
    
    var body: some View {
        VStack {
            if self.timeRemaining > 0 {
                Text("Time remaining")
                Text("\(timeRemaining)")
                    .onAppear() {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                            _ in if self.timeRemaining > 0 {
                                self.timeRemaining -= 1
                            }
                        })
                    }
                Text("seconds")
                Button(action: {
                    self.secondScreenShown = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
            }
            else {
                Button(action: {
                    self.secondScreenShown = false
                }) {
                    Text("Done")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

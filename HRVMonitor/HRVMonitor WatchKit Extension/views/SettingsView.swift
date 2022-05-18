//
//  SettingsView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI

struct SettingsView : View {
    let sex = ["Female", "Male"]
    
    @State private var selectedSex: Int = 0
    @State private var selectedAge: Int = 25
    @State private var isEditing = false
    @State private var formatter = NumberFormatter()
    
    @State private var isSaved: Bool = false
    @State private var saveButtonText: String = "Save"
    
    var body : some View {
        VStack {
            Text("Settings")
                .fontWeight(.semibold)
                .font(.system(size: 16))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
            VStack {
                HStack{
                    Text("Sex:")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Picker("", selection: $selectedSex) {
                        Text("Male").tag(0)
                        Text("Female").tag(1)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: 100)
                }
                HStack {
                    Text("Age:")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        Picker("", selection: $selectedAge) {
                            ForEach(1..<100) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .frame(maxWidth: 100)
                }
                                
                NavigationLink(destination: MonitorView()) {
                    Text("Done").fontWeight(.semibold)
                            .foregroundColor(BUTTON_COLOR)
                    }.padding(.horizontal, 40.0)
                        .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
            }
        }
    }

    func calculateButtonColor() -> Color {
        return self.isSaved ? Color.gray.opacity(0.8) : BUTTON_COLOR
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

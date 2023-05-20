//
//  SettingsView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//

import SwiftUI

/// A view that displays and allows editing of user settings.
struct SettingsView: View {
    @EnvironmentObject var storageService: StorageService
    
    /// Binding used to close the navigation link.
    @Binding var isSettingsViewActive: Bool
    
    @State var selectedSex: Int = 0
    @State var selectedAge: Int = 25
    
    var body: some View {
        VStack {
            Text("Settings")
                .fontWeight(.semibold)
                .font(.system(size: 16))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            VStack {
                HStack {
                    Text("Sex:")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    
                    Picker("", selection: self.$selectedSex) {
                        Text(PATIENT_SEX_LIST[0]).tag(0)
                        Text(PATIENT_SEX_LIST[1]).tag(1)
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
                    
                    Picker("", selection: self.$selectedAge) {
                        ForEach(1..<100, id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .frame(maxWidth: 100)
                }
                
                // Return to MonitorView
                Button(action: {
                    self.updatePatientSettings()
                    self.isSettingsViewActive = false
                }) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundColor(BUTTON_COLOR)
                }
                .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
                .padding(.horizontal, 40.0)
            }
        }
        .onAppear() {
            self.setCurrentPatientSettings()
        }
    }
    
    /// Sets the current patient settings.
    func setCurrentPatientSettings() {
        let patientSettings = self.storageService.getPatientSettings()
        
        // Set picker values
        self.selectedAge = patientSettings.age
        self.selectedSex = PATIENT_SEX_LIST.firstIndex(of: patientSettings.sex)!
    }

    /// Updates the patient settings.
    func updatePatientSettings() {
        let newPatientSettings = PatientSettings(age: self.selectedAge, sex: PATIENT_SEX_LIST[self.selectedSex])
        self.storageService.updateUserSettings(patientSettings: newPatientSettings)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSettingsViewActive: .constant(true))
    }
}

//
//  SettingsView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/3/22.
//
import SwiftUI

struct SettingsView : View {
    @EnvironmentObject var storageService: StorageService
    
    @State var selectedSex: Int = 0
    @State var selectedAge: Int = 25
    
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
                                
                NavigationLink(destination: MonitorView()) {
                    Text("Done").fontWeight(.semibold)
                            .foregroundColor(BUTTON_COLOR)
                }
                .padding(.horizontal, 40.0)
                .buttonStyle(BorderedButtonStyle(tint: Color.gray.opacity(0.2)))
                // we will update the patient settings when we use the navlink
                .simultaneousGesture(TapGesture().onEnded({
                    self.updatePatientSettings()
                }))
            }
        }
        .onAppear() {
            self.setCurrentPatientSettings()
        }
    }
    
    func setCurrentPatientSettings() {
        let patientSettings = self.storageService.getPatientSettings()
        
        // set our picker values
        self.selectedAge = patientSettings.age
        self.selectedSex = PATIENT_SEX_LIST.firstIndex(of: patientSettings.sex)!
    }

    func updatePatientSettings() {
        let newPatientSettings = PatientSettings(age: self.selectedAge, sex: PATIENT_SEX_LIST[self.selectedSex])
        self.storageService.updateUserSettings(patientSettings: newPatientSettings)
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

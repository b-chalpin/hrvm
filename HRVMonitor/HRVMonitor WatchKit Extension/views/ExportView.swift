//
//  ExportView.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/2/22.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var storageService: StorageService
    
    // used for exporting files to iOS app
    private let watchExportSession = WatchExportSession().session
    
    var body: some View {
        VStack {
            Text("EXPORT")
                .fontWeight(.semibold)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
            
            Text("Your data will be exported to your iPhone Files app. Find the file named: export.json")
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .multilineTextAlignment(.center)
                .font(.system(size: 14))
            
            Spacer()
            
            Button(action: {
                self.exportData()
            }) {
                    Text("Export")
                    .foregroundColor(BUTTON_COLOR)
            }
        }
    }
    
    private func exportData() {
        let json = self.storageService.exportAllDataToJson()
        sendDataToPhoneViaWC(dataToExport: json)
    }
    
    private func sendDataToPhoneViaWC(dataToExport: String) {
        guard let baseDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileUrl = baseDirUrl.appendingPathComponent("export.json")
        let string = dataToExport.data(using: .utf8)
        FileManager.default.createFile(atPath: fileUrl.path, contents: string)

        self.watchExportSession.transferFile(fileUrl, metadata: nil)
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}

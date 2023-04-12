//
//  ExportView.swift
//  HRVMonitor WatchKit Extension
// This is a Swift file for an ExportView SwiftUI view that allows users to export their HRV data to a file on their iPhone.
// The view contains a Text element that displays the title "EXPORT", followed by another Text element that provides instructions 
// to the user on where to find the exported file on their iPhone Files app.
// A Button element labeled "Export" is also present to initiate the export process.
// The view makes use of the StorageService class to retrieve the HRV data to be exported,
// and the WatchExportSession class to transfer the exported data to the iPhone.
// The exportData() function is used to retrieve the HRV data and initiate the export process. 
// The sendDataToPhoneViaWC() function is used to create a file with the data in JSON format, and then transfer it to the iPhone.
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

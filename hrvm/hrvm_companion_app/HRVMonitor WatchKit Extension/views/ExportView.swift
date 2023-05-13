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
    @EnvironmentObject var watchExportSession: WatchExportSession
    
    @State var isExported = false
    
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
            
            if (self.isExported) {
                Button(action: {
                    self.exportData()
                }) {
                        Text("Export")
                        .foregroundColor(BUTTON_COLOR)
                }
            }
            else {
                Button(action: {
                    // dummy button
                }) {
                        Text("Exported")
                        .foregroundColor(Color.gray)
                }
                .disabled(true)
            }
        }
        .onDisappear {
            self.isExported = false
        }
    }
    
    private func exportData() {
        let json = self.storageService.exportAllDataToJson()
        if let jsonDictionary = convertStringToDictionary(jsonString: json) {
            sendDataToPhoneViaWC(dataToExport: jsonDictionary)
        } else {
            print("Failed to convert JSON to dictionary")
        }
        // disable the button
        self.isExported = true
    }

    func convertStringToDictionary(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Error converting string to dictionary: \(error)")
        }
        
        return nil
    }
    
    private func sendDataToPhoneViaWC(dataToExport: [String: Any]) {
        guard let baseDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileName = "export_\(getCurrentTimestamp()).csv"
        let csvString = convertJSONToCSV(jsonDict: dataToExport)
        let fileUrl = baseDirUrl.appendingPathComponent(fileName)
        let fileContent = csvString.data(using: .utf8)
        FileManager.default.createFile(atPath: fileUrl.path, contents: fileContent)

        self.watchExportSession.session?.transferFile(fileUrl, metadata: nil)
    }

    func convertJSONToCSV(jsonDict: [String: Any]) -> String {
        var csvString = ""
        
        csvString.append("meanRR,avgHeartRateBPM,avgHeartRateMS,hr,unixTimestamp,timestamp,deltaUnixTimestamp,medianRR,deltaHrvValue,RMSSD,unixTimestamp,numHeartRateSamples,pNN50,isStressed\n")
        
        if let lrDataStore = jsonDict["lrDataStore"] as? [String: Any],
            let dataItems = lrDataStore["dataItems"] as? [[String: Any]] {
            
            for dataItem in dataItems {
                if let sample = dataItem["sample"] as? [[String: Any]],
                    let hrSamples = sample[0]["hrSamples"] as? [[String: Any]],
                    let isStressed = dataItem["isStressed"] as? Bool {
                    
                    if let sampleDict = sample[0] as? [String: Any],
                        let meanRR = sampleDict["meanRR"] as? Double,
                        let avgHeartRateBPM = sampleDict["avgHeartRateBPM"] as? Double,
                        let avgHeartRateMS = sampleDict["avgHeartRateMS"] as? Double,
                        let hrSample = hrSamples[0] as? [String: Any],
                        let hr = hrSample["hr"] as? Int,
                        let unixTimestamp = hrSample["unixTimestamp"] as? Double,
                        let timestamp = hrSample["timestamp"] as? Double,
                        let deltaUnixTimestamp = sampleDict["deltaUnixTimestamp"] as? Double,
                        let medianRR = sampleDict["medianRR"] as? Double,
                        let deltaHrvValue = sampleDict["deltaHrvValue"] as? Double,
                        let RMSSD = sampleDict["RMSSD"] as? Double,
                        let unixTimestamp2 = sampleDict["unixTimestamp"] as? Double,
                        let numHeartRateSamples = sampleDict["numHeartRateSamples"] as? Int,
                        let pNN50 = sampleDict["pNN50"] as? Int {
                        
                        let row = "\(meanRR),\(avgHeartRateBPM),\(avgHeartRateMS),\(hr),\(unixTimestamp),\(timestamp),\(deltaUnixTimestamp),\(medianRR),\(deltaHrvValue),\(RMSSD),\(unixTimestamp2),\(numHeartRateSamples),\(pNN50),\(isStressed)\n"
                        csvString.append(row)
                    }
                }
            }
        }
        return csvString
    }

    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}

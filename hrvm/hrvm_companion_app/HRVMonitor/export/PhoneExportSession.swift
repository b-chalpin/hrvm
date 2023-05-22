//
//  PhoneExportSession.swift
//  HRVMonitor
//
//  Created by bchalpin on 6/3/22.
//

import WatchConnectivity
import HealthKit
import SwiftUI


public class PhoneExportSession: NSObject, WCSessionDelegate, ObservableObject {
    public var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override init() {
        super.init()
        self.session?.delegate = self
        session?.activate()
    }
    
    /// need these function headers in order to implement WCSessionDelegate
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {}
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    public func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let srcUrl = file.fileURL
        
        guard FileManager.default.fileExists(atPath: file.fileURL.path) else {
            fatalError("File transferred from Watch does not exist")
        }
        
        let json = try! Data(contentsOf: srcUrl)
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: json, options: []) as? [[String: Any]] else {
            fatalError("Failed to parse JSON data")
        }
        
        let csv = convertJSONToCSV(jsonArray: jsonArray)
        
        let timestamp = getCurrentTimestamp()
        let filename = "export_\(timestamp).csv"
        
        let destUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename)
        
        do {
            try csv.write(to: destUrl, atomically: true, encoding: .utf8)
            // Move the file from Apple Watch to Files app
            try? FileManager.default.removeItem(at: srcUrl)
            self.session?.transferFile(destUrl, metadata: nil)
            
            /// Log message
            print("File received and converted to CSV. Filename: \(filename)")
            
            /// Present an alert
            let alert = UIAlertController(title: "File Received", message: "The file has been converted to CSV and saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        } catch {
            print("Error exporting data: \(error)")
        }
    }

    private func convertJSONToCSV(jsonArray: [[String: Any]]) -> String {
        guard let firstObject = jsonArray.first else {
            return ""
        }
        
        let headerRow = firstObject.keys.joined(separator: ",")
        var csvRows = [headerRow]
        
        for jsonObject in jsonArray {
            let values = jsonObject.values.map { String(describing: $0) }
            let csvRow = values.joined(separator: ",")
            csvRows.append(csvRow)
        }
        
        return csvRows.joined(separator: "\n")
    }

    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

}

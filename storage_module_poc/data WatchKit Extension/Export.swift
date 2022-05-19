//
//  Export.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 10/05/2022.
//

import SwiftUI
import CoreData

struct Export: View {
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        VStack(spacing: 15){
        Button(action: exportToCSV, label: {
            Text("Export to CSV")
                .padding(.vertical,10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color("blue"))
                .cornerRadius(15)
        })
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
    }
    }
    

    private func allItems() -> Array<Items>{
        let fetchRequest:NSFetchRequest<Items> = Items.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Items.events, ascending: false)]
        return try! context.fetch(fetchRequest)
    }
    
    private func converisonToCsv(items: Array<Items>)->String{

        
        
        var results = "Events, HrItem, HrvItem, monitorItem, \r"
        
        for itemIterator in items{
            results = results + "\"" + (itemIterator.events)! + "\"" + ","
            results = results + "\"" + (itemIterator.hrItem)! + "\"" + ","
            results = results + "\"" + (itemIterator.hrvItem)! + "\"" + ","
            results = results + "\"" + (itemIterator.monitorItem)! + "\"" + ","
            results = results + "\"" + "r"
        }
        return results
    }
    
    func exportToCSV(){
        //let contentToFile = converisonToCsv(items: allItems())
//        let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
//        let documentDirectoryURL = containerURL!.appendingPathComponent("Documents")
//        let documentURL = documentDirectoryURL.appendingPathComponent("myFile.txt")
//        let text = String("test message")
        if let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            if !FileManager.default.fileExists(atPath: containerUrl.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            
            let fileUrl = containerUrl.appendingPathComponent("hello.txt")
            do {
                try "Hello iCloud!".write(to: fileUrl, atomically: true, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
            
    }
    
}

struct Export_Previews: PreviewProvider {
    static var previews: some View {
        Export()
    }
}

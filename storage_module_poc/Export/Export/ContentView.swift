//
//  ContentView.swift
//  Export
//
//  Created by Jared adams on 20/05/2022.
//

import SwiftUI

struct ContentView: View {
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
    func exportToCSV(){
        let manager = FileManager.default
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }
        print(url.path)
        let newFolder = url.appendingPathComponent("Example")
        do{
            try manager.createDirectory(at: newFolder, withIntermediateDirectories: true)
        }
        catch{
            print("Error")
        }
        do{
            let fileUrl = newFolder.appendingPathComponent("logs.txt")
            manager.createFile(atPath: fileUrl.path, contents: nil, attributes: [FileAttributeKey.creationDate:Date()])
        }
        UIApplication.shared.open(url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

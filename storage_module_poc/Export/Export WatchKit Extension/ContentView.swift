//
//  ContentView.swift
//  Export WatchKit Extension
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
        //create a FileManager object to allow for access to the file system
        let manager = FileManager.default
        
        //This is to get the path to the documents for the user and it returns an array of one so you do .first to make it easier
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }
        //The .path will print the url path to the file
        print(url.path)
        let newFolder = url.appendingPathComponent("Example")
        do{
            //CreateDirectory will allow the person to create a folder inside the path directed to
            try manager.createDirectory(at: newFolder, withIntermediateDirectories: true)
        }
        catch{
            print("Error")
        }
        do{
            //creating a file to the path specified, and the file with the date add to its attributes also its created with data. You have to convert the string into a data type
            let string = "Hello World".data(using: .utf8)
            let fileUrl = newFolder.appendingPathComponent("logs.txt")
            manager.createFile(atPath: fileUrl.path, contents: string, attributes: [FileAttributeKey.creationDate:Date()])
        }
        // to write to a file that is already created
        let string = "Updated String".data(using: .utf8)
        
        let fileUrl = newFolder.appendingPathComponent("logs2.txt")
        do{
            try string?.write(to: fileUrl)
        } catch{
             print("error")
            }


    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

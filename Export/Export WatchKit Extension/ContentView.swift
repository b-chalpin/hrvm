//
//  ContentView.swift
//  Export WatchKit Extension
//
//  Created by Jared adams on 20/05/2022.
//

import SwiftUI

struct ContentView: View {
    var model = WatchView()
    @State var messageText = ""
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
        guard let dirForTransfer = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return
        }
        let file = dirForTransfer.appendingPathComponent("ExportedFile.txt")
            let string = "Hello World".data(using: .utf8)
            FileManager.default.createFile(atPath: file.path, contents: string)
        //print(file.path)
        

         
        self.model.session.sendMessage(["message" : "This is an example text"], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        print("File sent")
        }
    }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  Add.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 06/05/2022.
//

import SwiftUI

struct Add: View {
    let container = PersistenceController.shared.container
    @State var ModelItems=""
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentation
    
    //This allows for editing the date inside of the data
    var modelItem: Items?
    
    
    var body: some View {
        VStack(spacing: 15){
            TextField("Data ", text: $ModelItems)
            
            Button(action: AddToData, label: {
                Text("Save")
                    .padding(.vertical,10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color("blue"))
                    .cornerRadius(15)
            })
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                .disabled(ModelItems=="")
        }
        .navigationTitle("\(modelItem == nil ? "Add Data" : "Update Data")")
        .onAppear(perform: {
            
            //Checking if there is an item that has to be edited
            if let model = modelItem{
                ModelItems  = model.hrvIte ??  ""
            }
        })
    }
    
    
    func AddToData(){
        //Checking if the Core has Data
        let model = modelItem == nil ? Items(context: context) : modelItem!
        
        //This is where you add Set the items for saving
        model.hrvIte = ModelItems+" : This is saved data"
        model.hrIte = "HrItem Is added"
        model.monitorIte = "MonitorItem is added"
        model.event = "Events is added"
        
        //Trying to save the data
        do{
            try context.save()
            //if it was success full it will close the view
            presentation.wrappedValue.dismiss()
        }
        catch{
            print(error.localizedDescription)
            
        }
        
    }
}


struct Add_Previews: PreviewProvider {
    static var previews: some View {
        Add()
    }
}

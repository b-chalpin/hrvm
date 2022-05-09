//
//  delete.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 09/05/2022.
//

import SwiftUI

struct delete: View {
    
    //fetching the data as a list
    @FetchRequest(entity: Items.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Items.event, ascending: false)], animation: .easeIn) var results : FetchedResults<Items>
    
    //For deleting
    @State var deleteDataItem : Items?
    @State var deleteData = false
    
    // The context
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        List(results){item in
            HStack(spacing: 10){
                VStack(alignment: .leading, spacing: 3, content: {
                Text(item.hrvIte ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.monitorIte ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.hrIte ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.event ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
            })
            
            Spacer(minLength: 4)
             
                Button(action: {
                    deleteDataItem = item
                    deleteData.toggle()
                }, label:{
                Image(systemName: "trash")
                    .frame(width: 3.0, height: 2.0)
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.yellow)
                    .cornerRadius(8)
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(CarouselListStyle())
        .padding(.top)
        .overlay(
        
            Text(results.isEmpty ? "No Data to delete" : "")
        )
        .navigationTitle("Delete")
        .alert(isPresented: $deleteData, content: {
            Alert(title: Text("Delete Data?"), message: Text("This is to delete this message"), primaryButton: .default(Text("Yes"), action: {
                
                deleteData(model: deleteDataItem!)
            }), secondaryButton: .destructive(Text("Cancel?")))
        })
    }
    func deleteData(model: Items){
        context.delete(model)
        do{
            try context.save()
            }
        catch{
            print(error.localizedDescription)
        }
    }
}

struct delete_Previews: PreviewProvider {
    static var previews: some View {
        delete()
    }
}

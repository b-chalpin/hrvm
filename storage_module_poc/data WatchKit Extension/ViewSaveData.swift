//
//  ViewSaveData.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 09/05/2022.
//

import SwiftUI
import CoreData

struct ViewSaveData: View {
    //To request a fetch of the Core Data items
    
    //Getting Items(The Models) from descending order
    @FetchRequest(entity: Items.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Items.events, ascending: false)], animation: .easeIn) var results : FetchedResults<Items>
    
    var body: some View {
        List(results){item in
            HStack(spacing: 10){
                VStack(alignment: .leading, spacing: 3, content: {
                Text(item.hrvItem ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.monitorItem ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.hrItem ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
                Text(item.events ?? "")
                    .font(.system(size:12))
                    .foregroundColor(.white)
            })
            
            Spacer(minLength: 4)
             
                NavigationLink(destination: Add(modelItem: item), label: {
                Image(systemName: "Compose")
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
        
            Text(results.isEmpty ? "No Data is saved" : "")
        )
        .navigationTitle("Data")
    }
}

struct ViewSaveData_Previews: PreviewProvider {
    static var previews: some View {
        ViewSaveData()
    }
}

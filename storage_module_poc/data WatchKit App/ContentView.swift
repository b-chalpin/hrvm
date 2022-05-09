//
//  ContentView.swift
//  data WatchKit Extension
//
//  Created by Jared adams on 05/05/2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        GeometryReader{reader in
            
            let rect=reader.frame(in: .global )
            VStack(spacing: 15){
                HStack(spacing: 25){
                    //buttons
                    
                    NavigationLink(destination: Add(),label:{
                        NavButton(image: "plus", title: "Save", rect: rect, color: Color("blue"))
                    })
                        .buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: ViewSaveData(),label:{
                    NavButton(image: "star", title: "View", rect: rect, color: Color("red"))
                     })}
                .frame(width: rect.width, alignment: .center)
                HStack(spacing: 25){
                    NavigationLink(destination: delete(),label:{
                    NavButton(image: "trash", title: "Trash", rect: rect, color: Color("orange"))
                    })
                }
                .frame(width: rect.width, alignment: .center)
            }
            
        }
    }
}

struct NavButton: View{
    var image: String
    var title: String
    var rect: CGRect
    var color: Color
    
    var body: some View{
        VStack(spacing: 8){
            Image(systemName: image)
                .font(.title2)
                .frame(width: rect.width / 3, height: rect.width/3,  alignment: .center)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ButtonView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import SwiftUI

struct ButtonView: View {
    
    @State private var isPlaying : Bool = false
    
    var player = PlayerWord()
    
    
    var body: some View {
        Button {
            isPlaying.toggle()
            print("isPlaying \(isPlaying)")
           
            
          
        } label: {
            
            isPlaying == true ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
            
        }.foregroundColor(Color.orange)
    }
    
    
    
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView()
    }
}

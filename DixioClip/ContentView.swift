//
//  ContentView.swift
//  DixioClip
//
//  Created by Alvar Arias on 2023-04-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack {
            Image(systemName: "app.dashed")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, DIXIO CLIP")
            SharedView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

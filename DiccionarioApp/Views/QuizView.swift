//
//  QuizView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI
import CoreData

struct QuizView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: myWord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
        animation: .default
    )
    private var words: FetchedResults<myWord>
    
    @State private var randomIndex: Int = 0
    
    private func updateRandomIndex() {
        if !words.isEmpty {
            randomIndex = Int.random(in: 0..<words.count)
        }
    }
    
    var body: some View {
        VStack {
            if !words.isEmpty {
                Text(words[randomIndex].value ?? "No value")
                    .font(.headline)
                Text(words[randomIndex].type ?? "No type")
                    .font(.subheadline)
                Text(words[randomIndex].translation ?? "no information")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No words available.")
                    .font(.headline)
            }
            
            Button("Next Question") {
                updateRandomIndex()
            }
            .padding()
        }
        .onAppear(perform: updateRandomIndex)
       
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}

/*
 import SwiftUI
 import CoreData

 struct QuizView: View {
     @Environment(\.managedObjectContext) private var viewContext
     
     @FetchRequest(
         entity: myWord.entity(),
         sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
         animation: .default
     )
     private var words: FetchedResults<myWord>
     
     @State private var randomIndex: Int = 0
     
     private func updateRandomIndex() {
         if !words.isEmpty {
             randomIndex = Int.random(in: 0..<words.count)
         }
     }
     
     var body: some View {
         VStack {
             if !words.isEmpty {
                 Text(words[randomIndex].value ?? "No value")
                     .font(.headline)
                 Text(words[randomIndex].type ?? "No type")
                     .font(.subheadline)
                 Text(words[randomIndex].translation ?? "no information")
                     .font(.caption)
                     .foregroundColor(.secondary)
             } else {
                 Text("No words available.")
                     .font(.headline)
             }
             
             Button("Next Question") {
                 updateRandomIndex()
             }
             .padding()
         }
         .onAppear(perform: updateRandomIndex)
     }
 }


*/

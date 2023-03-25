//
//  QuizView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI
import CoreData

struct QuizView: View {
    
    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
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
        NavigationView {
         
                VStack {
                    
                    List {
                    
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
                .scrollContentBackground(.hidden)
                .navigationTitle(LocalizedStringKey("quiz"))
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: updateRandomIndex)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.down")
                                .foregroundColor(Color.orange)
                        }
                        
                    }
                    
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(UIColor(red: 0.45, green: 0.92, blue: 0.84, alpha: 0.5)),
                                Color(UIColor(red: 0.67, green: 0.71, blue: 0.90, alpha: 0.5))
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}


//
//  FavoriteView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import SwiftUI

struct FavoriteView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var wordListViewModel = WordListViewModel()

    
    var body: some View {
        NavigationView {
                    VStack {
                        List {
                            ForEach(wordListViewModel.favoriteWords, id: \.self) { word in
                                
                                    Text(word)
                              
                            }
                            .onDelete(perform: wordListViewModel.removeWord)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Favorite Words")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: EditButton())
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
    }

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}

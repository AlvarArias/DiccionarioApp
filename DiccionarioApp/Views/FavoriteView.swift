//
//  FavoriteView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import SwiftUI

struct FavoriteView: View {
    
    //MARK: Env
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var wordListViewModel = WordListViewModel()

    @Binding var searchWors: [String]
    
    var body: some View {
      
            NavigationView {
                
                VStack {
                    
                    List {
                        ForEach(searchWors, id: \.self) { word in
                            
                            Text(word)
                            
                        }
                        
                        
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("History Words")
                .navigationBarTitleDisplayMode(.inline)
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
        FavoriteView( searchWors: .constant([""]))
    }
}

//
//  WordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct WordView: View {
    
    @ObservedObject var myviewModelWord = WordViewModel()
    @State private var text = ""
    @State private var enableLang = true
    @State private var showFavorite = false
    
    @State private var errorMessage: String = ""
    
    var body: some View {
        
        NavigationView {
            
            Form {
                Section {
                    Toggle("Select Language", isOn: $enableLang)
                        .tint(.orange).opacity(0.7)
                    
                    Text(enableLang == true ? "swe_spa" : "spa_swe")
                        .listRowSeparator(.hidden)
                    
                    Text("\(errorMessage)")
                        .listRowSeparator(.hidden)
                        .onReceive(myviewModelWord.errorPublisher) { errorMessage in
                            self.errorMessage = errorMessage
                        }
                }
                
                
                HStack {
                    TextField("Search", text: $text)
                        .padding(.horizontal, 10)
                        .accentColor(.orange)
                        .accessibilityIdentifier("Search")
                    
                    Button {
                        print("Search")
                        if text != "" {
                            print(text)
                            myviewModelWord.fetchPosts(word: text, dir: enableLang == true ? "to" : "from")
                        }
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(UIColor.gray))
                    }
                    .accessibilityIdentifier("Button Search")
                    
                }
                .padding(.vertical, 10)
                //.background(Color(UIColor.orange).opacity(0.4))
                .cornerRadius(10)
                
                
                if errorMessage == "OK" {
                    
                    List( myviewModelWord.results, id: \.self) { resul in
                        
                        NavigationLink(destination: DetailView(result: resul)) {
                            
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    Text(resul.value ?? "No value")
                                        .font(.headline)
                                    Spacer()
                                    
                                    Text(resul.type ?? "No type")
                                        .font(.subheadline)
                                    
                                }
                                
                                Text(resul.baseLang?.meaning ?? "No meaning")
                                Text(resul.targetLang?.translation ?? "no translation")
                            }
                            .accessibilityIdentifier("link")
                        }
                        
                        
                    }
                    
                }
                
            }
            .navigationTitle("Diccionary")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
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
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                
                
                Button { showFavorite.toggle()
                } label: {
                    Image(systemName: "star")
                        .foregroundColor(Color.orange)
                }
                .sheet(isPresented: $showFavorite) {
                    
                    FavoriteView()
                }
            }
        }
    }
}

struct WordView_Previews: PreviewProvider {
    static var previews: some View {
        WordView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal, 10)
            Button {
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}


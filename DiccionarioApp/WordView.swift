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
    
    @State private var errorMessage: String = ""
    
    var body: some View {
        
        NavigationView {
            
            Form {
                Section {
                    Toggle("Select Language", isOn: $enableLang)
                    
                    Text(enableLang == true ? "swe_spa" : "spa_swe")
                    
                    /*
                    Text(myviewModelWord.mje)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                   */
                    Text("\(errorMessage)")
                        .onReceive(myviewModelWord.errorPublisher) { errorMessage in
                            self.errorMessage = errorMessage
                
                }
                }
                
                
                HStack {
                    TextField("Search", text: $text)
                        .padding(.horizontal, 10)
                    Button {
                        print("Search")
                        if text != "" {
                            print(text)
                            myviewModelWord.fetchPosts(word: text, dir: enableLang == true ? "to" : "from")
                        }
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                    }
                    
                }
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                if errorMessage == "OK" {
                
                    List( myviewModelWord.results, id: \.self) { resul in
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
                        
                    }
                    
                }
            }
            .navigationTitle("Diccionary")
            .navigationBarTitleDisplayMode(.inline)
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


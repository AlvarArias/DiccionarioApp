//
//  SearchBarView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct SearchBarView: View {
    
    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @Binding var text: String
    @Binding var searchWords: [String]
    @Binding var showProgressBar: Bool
    var myviewModelWord: WordViewModel
    var selectedLang: Bool
    
    var body: some View {
        HStack {
            TextField(LocalizedStringKey("search"), text: $text, onCommit: {
                performSearch()
            })
                .padding(.horizontal, 10)
                .accentColor(.blue)
                .accessibilityIdentifier("Search")
            
            Button {
                performSearch()
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(UIColor.gray))
            }
            .accessibilityIdentifier("Button Search")
        }
        .padding(15)
        .background(Color(UIColor.orange).opacity(0.4))
        .cornerRadius(10)
        .padding(.horizontal)
        .shadow(color: .orange, radius: 0.5, x: 0.5, y: -0.5)
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
    
    private func performSearch() {
        if text != "" {
            print(text)
            myviewModelWord.fetchPosts(word: text, dir: selectedLang == true ? "to" : "from")
            
            let newWord = text
            searchWords.append(newWord)
            
            showProgressBar = true
            
            text = ""
        }
    }
}

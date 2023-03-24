//
//  FavoriteModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import Foundation
import SwiftUI
import Combine

class WordListViewModel: ObservableObject {
    @Published var favoriteWords: [String] {
        didSet {
            UserDefaults.standard.set(favoriteWords, forKey: "FavoriteWords")
        }
    }
    
    init() {
        self.favoriteWords = UserDefaults.standard.stringArray(forKey: "FavoriteWords") ?? []
    }
    
    func addWord(_ word: String) {
        favoriteWords.append(word)
    }
    
    func removeWord(at offsets: IndexSet) {
        favoriteWords.remove(atOffsets: offsets)
    }
}


/*
class WordListViewModel: ObservableObject {
    @Published var favoriteWords: [String: String] {
        didSet {
            UserDefaults.standard.setValue(favoriteWords, forKey: "FavoriteWords")
        }
    }
    
    init() {
        self.favoriteWords = UserDefaults.standard.dictionary(forKey: "FavoriteWords") as? [String: String] ?? [:]
    }
    
    func addWord(key: String, value: String) {
        favoriteWords[key] = value
    }
    
    func removeWord(forKey key: String) {
        favoriteWords.removeValue(forKey: key)
    }
}

*/


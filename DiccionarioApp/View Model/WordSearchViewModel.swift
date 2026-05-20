//
//  WordSearchViewModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2026-05-20.
//

import Foundation
import NaturalLanguage
import UIKit

@MainActor
class WordSearchViewModel: ObservableObject {

    // MARK: Published
    @Published var selectedLang: Bool = true
    @Published var errorMessage: String = ""
    @Published var showProgressBar: Bool = false
    @Published var searchWords: [String] = []

    // MARK: Child ViewModels
    let wordViewModel = WordViewModel()
    let wordListViewModel = WordListViewModel()

    // MARK: Search

    func performSearch(text: String) {
        let normalized = text.lowercased()
        guard !normalized.isEmpty else { return }

        let dir: String
        if let detected = detectLanguage(for: normalized) {
            selectedLang = detected
            dir = detected ? "swe" : "spa"
        } else {
            selectedLang = true
            dir = "swe"
        }

        wordViewModel.fetchPosts(word: normalized, dir: dir)

        if !searchWords.contains(normalized) {
            searchWords.append(normalized)
        }

        showProgressBar = true
    }

    func suggestions(for text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        let personal = Array(Set(searchWords + wordListViewModel.favoriteWords))
            .filter { $0.localizedCaseInsensitiveContains(text) }
        let system = systemCompletions(for: text)
            .filter { !personal.contains($0) }
        return Array((personal + system).prefix(8)).sorted()
    }

    func voiceLocale() -> Locale {
        selectedLang ? Locale(identifier: "sv-SE") : Locale(identifier: "es-MX")
    }

    // MARK: Private

    // Returns true if Swedish (dir="swe"), false if Spanish (dir="spa"), nil if uncertain
    private func detectLanguage(for input: String) -> Bool? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(input)
        switch recognizer.dominantLanguage {
        case .swedish: return true
        case .spanish: return false
        default:       return nil
        }
    }

    private func systemCompletions(for input: String) -> [String] {
        guard input.count >= 2 else { return [] }
        let lang = detectLanguage(for: input) == false ? "es" : "sv"
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: input.utf16.count)
        return checker.completions(forPartialWordRange: range, in: input, language: lang) ?? []
    }
}

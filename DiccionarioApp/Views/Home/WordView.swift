//
//  WordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI
import NaturalLanguage

struct WordView: View {

    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment

    // MARK: ObsObjects
    @ObservedObject var myviewModelWord = WordViewModel()
    @StateObject private var wordListViewModel = WordListViewModel()

    // MARK: State
    @State private var text = ""
    @State private var selectedLang = true
    @State private var errorMessage: String = ""
    @State private var showProgressBarr = false

    @State private var showHistory = false
    @State private var showSavedWord = false
    @State private var showQuiz = false
    @State private var showSettings = false

    @State private var isVStackVisible = false
    @State private var newWord: String = ""
    @State var searchWords: [String] = []
    @State private var selectedTab = 1

    // Combines session history + UserDefaults favorites, filtered by current text
    var filteredSuggestions: [String] {
        guard !text.isEmpty else { return [] }
        let combined = Array(Set(searchWords + wordListViewModel.favoriteWords))
        return combined
            .filter { $0.localizedCaseInsensitiveContains(text) }
            .sorted()
    }

    var body: some View {

        NavigationStack {

            VStack {

                // Selection Lang View
                LanguageSelectionView(
                    selectedLang: $selectedLang,
                    errorMessage: $errorMessage,
                    showProgressBar: $showProgressBarr,
                    myviewModelWord: myviewModelWord
                )

                ScrollView {

                    if showProgressBarr {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    }

                    if errorMessage == "OK" {
                        ResultsListView(
                            selectedLang: $selectedLang,
                            isVStackVisible: $isVStackVisible,
                            showProgressBar: $showProgressBarr,
                            myviewModelWord: myviewModelWord
                        )
                    }

                }

            }
            .navigationTitle(LocalizedStringKey("home"))
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
            .searchable(text: $text, prompt: LocalizedStringKey("search"))
            .searchSuggestions {
                ForEach(filteredSuggestions, id: \.self) { suggestion in
                    Button {
                        text = suggestion
                        performSearch()
                    } label: {
                        Label(suggestion, systemImage: "clock")
                    }
                }
            }
            .onSubmit(of: .search) {
                performSearch()
            }

        }

        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                settingsButton()
                Spacer()
                quizButton()
                Spacer()
                cardButton()
                Spacer()
                savedWordButton()
            }
        }

        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))

    }

    private func performSearch() {
        guard !text.isEmpty else { return }

        if let detected = detectLanguage(for: text) {
            selectedLang = detected
        }

        myviewModelWord.fetchPosts(word: text, dir: selectedLang ? "to" : "from")

        if !searchWords.contains(text) {
            searchWords.append(text)
        }

        showProgressBarr = true
    }

    // Returns true (spa→swe) or false (swe→spa), nil if language is uncertain
    private func detectLanguage(for input: String) -> Bool? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(input)
        switch recognizer.dominantLanguage {
        case .swedish: return false
        case .spanish: return true
        default:       return nil
        }
    }

    private func cardButton() -> some View {
        Button(action: { showHistory.toggle() }) {
            Image(systemName: "menucard")
                .foregroundColor(Color.orange)
        }
        .sheet(isPresented: $showHistory) {
            QuizView()
        }
    }

    private func quizButton() -> some View {
        Button(action: { showQuiz.toggle() }) {
            Image(systemName: "questionmark.bubble")
                .foregroundColor(Color.orange)
        }
        .sheet(isPresented: $showQuiz) {
            TriviaView()
        }
    }

    private func settingsButton() -> some View {
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "gear")
                .foregroundColor(Color.orange)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func savedWordButton() -> some View {
        Button(action: { showSavedWord.toggle() }) {
            Image(systemName: "checklist.checked")
                .foregroundColor(Color.orange)
        }
        .sheet(isPresented: $showSavedWord) {
            SavedWordView()
        }
    }
}

#Preview {
    WordView()
}

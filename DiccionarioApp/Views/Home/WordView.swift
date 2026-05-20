//
//  WordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI
import NaturalLanguage
import UIKit

struct WordView: View {

    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment

    // MARK: ObsObjects
    @ObservedObject var myviewModelWord = WordViewModel()
    @StateObject private var wordListViewModel = WordListViewModel()
    @StateObject private var speech = SpeechRecognizer()

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

    // Combines session history + UserDefaults favorites + system dictionary, filtered by current text
    var filteredSuggestions: [String] {
        guard !text.isEmpty else { return [] }
        let personal = Array(Set(searchWords + wordListViewModel.favoriteWords))
            .filter { $0.localizedCaseInsensitiveContains(text) }
        let system = systemCompletions(for: text)
            .filter { !personal.contains($0) }
        return Array((personal + system).prefix(8)).sorted()
    }

    private func systemCompletions(for input: String) -> [String] {
        guard input.count >= 2 else { return [] }
        let lang = detectLanguage(for: input) == false ? "es" : "sv"
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: input.utf16.count)
        return checker.completions(forPartialWordRange: range, in: input, language: lang) ?? []
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
            .searchable(text: $text, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStringKey("search"))
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    micButton()
                }
            }
            .onChange(of: speech.transcript) { _, newValue in
                text = newValue
            }
            .onChange(of: speech.isRecording) { _, isRecording in
                if !isRecording && !speech.transcript.isEmpty {
                    text = speech.transcript
                    performSearch()
                }
            }
            .alert("Microphone Access", isPresented: $speech.permissionDenied) {
                Button("OK") { }
            } message: {
                Text("Enable microphone access in Settings to use voice search.")
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

        let normalizedText = text.lowercased()
        let dir: String

        if let detected = detectLanguage(for: normalizedText) {
            selectedLang = detected
            dir = detected ? "swe" : "spa"
        } else {
            // Word too short or ambiguous — default to Swedish→Spanish
            selectedLang = true
            dir = "swe"
        }

        myviewModelWord.fetchPosts(word: normalizedText, dir: dir)

        if !searchWords.contains(normalizedText) {
            searchWords.append(normalizedText)
        }

        showProgressBarr = true
    }

    // Returns true if Swedish (selectedLang=true → show Spanish translation, dir="swe")
    // Returns false if Spanish (selectedLang=false → show Swedish meaning, dir="spa")
    // Returns nil if uncertain
    private func detectLanguage(for input: String) -> Bool? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(input)
        switch recognizer.dominantLanguage {
        case .swedish: return true
        case .spanish: return false
        default:       return nil
        }
    }

    private func micButton() -> some View {
        Button {
            let locale = selectedLang ? Locale(identifier: "sv-SE") : Locale(identifier: "es-MX")
            speech.toggle(locale: locale)
        } label: {
            Image(systemName: speech.isRecording ? "mic.fill" : "mic")
                .foregroundColor(speech.isRecording ? .red : .orange)
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

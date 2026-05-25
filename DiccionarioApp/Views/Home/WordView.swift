//
//  WordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct WordView: View {

    // MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment

    // MARK: ViewModels
    @StateObject private var viewModel = WordSearchViewModel()
    @StateObject private var speech = SpeechRecognizer()

    // MARK: State
    @State private var text = ""
    @State private var isVStackVisible = false
    @State private var showHistory = false
    @State private var showSavedWord = false
    @State private var showQuiz = false
    @State private var showSettings = false

    var body: some View {

        NavigationStack {

            VStack {

                LanguageSelectionView(
                    selectedLang: $viewModel.selectedLang,
                    errorMessage: $viewModel.errorMessage,
                    showProgressBar: $viewModel.showProgressBar,
                    myviewModelWord: viewModel.wordViewModel
                )

                ScrollView {

                    if viewModel.showProgressBar {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    }

                    if viewModel.errorMessage == "OK" {
                        ResultsListView(
                            selectedLang: $viewModel.selectedLang,
                            isVStackVisible: $isVStackVisible,
                            showProgressBar: $viewModel.showProgressBar,
                            myviewModelWord: viewModel.wordViewModel
                        )
                    }

                }

            }
            .navigationTitle(LocalizedStringKey("home"))
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .searchable(text: $text, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStringKey("search"))
            .searchSuggestions {
                ForEach(viewModel.suggestions(for: text), id: \.self) { suggestion in
                    Button {
                        text = suggestion
                        viewModel.performSearch(text: suggestion)
                    } label: {
                        Label(suggestion, systemImage: "clock")
                    }
                }
            }
            .onSubmit(of: .search) {
                viewModel.performSearch(text: text)
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
                    viewModel.performSearch(text: text)
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

    // MARK: Toolbar Buttons

    private func micButton() -> some View {
        Button {
            speech.toggle(locale: viewModel.voiceLocale())
        } label: {
            Image(systemName: speech.isRecording ? "mic.fill" : "mic")
                .foregroundColor(speech.isRecording ? .red : .appPrimary)
        }
    }

    private func cardButton() -> some View {
        Button(action: { showHistory.toggle() }) {
            Image(systemName: "menucard")
                .foregroundColor(Color.appPrimary)
        }
        .sheet(isPresented: $showHistory) {
            QuizView()
        }
    }

    private func quizButton() -> some View {
        Button(action: { showQuiz.toggle() }) {
            Image(systemName: "questionmark.bubble")
                .foregroundColor(Color.appPrimary)
        }
        .sheet(isPresented: $showQuiz) {
            TriviaView()
        }
    }

    private func settingsButton() -> some View {
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "gear")
                .foregroundColor(Color.appPrimary)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func savedWordButton() -> some View {
        Button(action: { showSavedWord.toggle() }) {
            Image(systemName: "checklist.checked")
                .foregroundColor(Color.appPrimary)
        }
        .sheet(isPresented: $showSavedWord) {
            SavedWordView()
        }
    }
}

#Preview {
    WordView()
}

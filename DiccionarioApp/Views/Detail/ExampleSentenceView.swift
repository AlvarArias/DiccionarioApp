//
//  ExampleSentenceView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2026-05-20.
//

import SwiftUI
import FoundationModels

struct ExampleSentenceView: View {

    let word: String
    let selectedLang: Bool  // true = Spanish word, false = Swedish word

    @State private var sentence: String = ""
    @State private var isGenerating = false
    @State private var errorMessage: String = ""

    private var language: String { selectedLang ? "Spanish" : "Swedish" }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AI Example")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    Task { await generateSentence() }
                } label: {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.orange)
                    }
                }
                .disabled(isGenerating)
            }

            if !sentence.isEmpty {
                Text(sentence)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .animation(.easeIn, value: sentence)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .listRowSeparator(.hidden)
    }

    private func generateSentence() async {
        guard SystemLanguageModel.default.isAvailable else {
            errorMessage = "Apple Intelligence not available on this device."
            return
        }

        isGenerating = true
        sentence = ""
        errorMessage = ""

        do {
            let session = LanguageModelSession()
            let prompt = "Write one short, simple example sentence in \(language) using the word '\(word)'. Return only the sentence, nothing else."

            for try await partial in session.streamResponse(to: prompt) {
                sentence = partial.content
            }
        } catch {
            errorMessage = "Could not generate example."
        }

        isGenerating = false
    }
}

#Preview {
    Form {
        ExampleSentenceView(word: "spring", selectedLang: false)
    }
}

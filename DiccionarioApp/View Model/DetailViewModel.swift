//
//  DetailViewModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2026-05-20.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

@MainActor
class DetailViewModel: ObservableObject {

    @Published var isSaved: Bool = false
    @Published var isDuplicate: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    // MARK: CoreData

    func saveWord(result: Result, selectedLang: Bool, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<myWord> = myWord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "value == %@", result.value ?? "")

        do {
            let existing = try context.fetch(fetchRequest)

            if existing.isEmpty {
                let word = myWord(context: context)
                word.value = result.value ?? "No value"
                word.type = result.type ?? "No type"
                word.phonetic = result.baseLang?.phonetic?.content ?? ""
                word.file = result.baseLang?.phonetic?.file ?? ""

                if selectedLang {
                    word.translation = result.targetLang?.translation ?? "No translation"
                    word.synonym = result.targetLang?.synonym?.first ?? ""
                } else {
                    word.meaning = result.baseLang?.meaning ?? "No meaning"
                }

                try context.save()
                showSaved()
            } else {
                print("Word already exists in Core Data")
                showDuplicate()
            }
        } catch {
            print("Error saving word: \(error)")
        }
    }

    // MARK: Text to Speech

    func speak(word: String, language: String = "es-MX") {
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.1
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }

    // MARK: Private

    private func showSaved() {
        isSaved = true
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation { isSaved = false }
        }
    }

    private func showDuplicate() {
        isDuplicate = true
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation { isDuplicate = false }
        }
    }
}

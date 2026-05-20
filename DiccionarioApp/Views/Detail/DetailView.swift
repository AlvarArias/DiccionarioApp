//
//  DetailView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI
import CoreData

struct DetailView: View {

    // MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.managedObjectContext) var context

    // MARK: ViewModels
    @StateObject private var viewModel = DetailViewModel()
    @ObservedObject var player = PlayerWord()

    // MARK: Input
    @Binding var selectedLang: Bool
    let result: Result

    var body: some View {

        Form {

            WordInfoView(result: result, saveWordToCoreData: {
                viewModel.saveWord(result: result, selectedLang: selectedLang, context: context)
            })

            LanguageInfoView(result: result, selectedLang: selectedLang)

            if selectedLang {
                AudioPlaybackView(player: player, phonetic: result.baseLang?.phonetic)
            }

            ExampleSentenceView(word: result.value ?? "", selectedLang: selectedLang)

        }
        .shadow(color: .gray, radius: 0.5, x: 0.5, y: -0.5)
        .padding()
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
        .overlay(
            Group {
                if viewModel.isSaved {
                    NotificationCore(text: LocalizedStringKey("saving"))
                        .transition(.move(edge: .top))
                }
                if viewModel.isDuplicate {
                    NotificationCore(text: "The word already saved")
                        .transition(.move(edge: .top))
                }
            }
        )
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

#Preview {
    DetailView(
        player: PlayerWord(),
        selectedLang: .constant(false),
        result: .init(
            variantID: "variantID", value: "value", type: "type",
            baseLang: BaseLang(phonetic: Phonetic(file: "file", content: "content"), inflection: [Inflection(content: "content")], meaning: "meaning", illustration: [Illustration(type: "type", value: "value")], comment: "comment"),
            targetLang: TargetLang(translation: "translation", synonym: ["synonym"], comment: "comment")
        )
    )
}

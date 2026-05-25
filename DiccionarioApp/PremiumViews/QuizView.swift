//
//  QuizView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI
import CoreData

struct QuizView: View {

    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: myWord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
        animation: .default
    )
    private var words: FetchedResults<myWord>

    @StateObject private var viewModel = QuizViewModel()

    @State private var flipped = false
    @State private var rotationAngle: Double = 0.0

    var body: some View {

        ZStack {

            Color.appBackground

            VStack {

                Text("Cards").font(.title)
                    .padding()

                if words.isEmpty {
                    Spacer()
                    Text("Save words first to use flashcards.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    VStack {
                        if flipped {
                            BackOfCardView(myTranslation: words[viewModel.randomIndex].translation ?? "No translation")
                                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                        } else {
                            FrontOfCardView(myWord: words[viewModel.randomIndex].value ?? "No word")
                                .id(words[viewModel.randomIndex].value)
                                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            flipped.toggle()
                            rotationAngle += 360
                        }
                    }
                    .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                    .padding()

                    Button("Next Card") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            rotationAngle += 360
                        }
                        Task {
                            try? await Task.sleep(for: .seconds(0.15))
                            withAnimation(.easeInOut(duration: 0.5)) {
                                viewModel.updateRandomIndex(words: Array(words))
                                flipped = false
                            }
                        }
                    }
                    .padding()
                }

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "arrow.down")
                        .foregroundColor(Color.appPrimary)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.gray, radius: 4, x: 0, y: 2)
            .padding()
        }
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

#Preview {
    QuizView()
}

struct FrontOfCardView: View {

    @State var myWord: String

    var body: some View {
        ZStack {
            Color.appSurface
            Text(myWord)
                .foregroundColor(Color.onBackground)
        }
        .frame(width: 200, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.gray, radius: 1, x: 0, y: 2)
    }
}

struct BackOfCardView: View {

    @State var myTranslation: String

    var body: some View {
        ZStack {
            Color.appPrimary.opacity(0.7)
            Text(myTranslation)
                .foregroundColor(Color.onPrimary)
        }
        .frame(width: 200, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.gray, radius: 1, x: 0, y: 2)
    }
}

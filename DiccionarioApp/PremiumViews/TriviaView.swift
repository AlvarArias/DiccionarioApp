//
//  TriviaView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-26.
//

import SwiftUI
import CoreData
import ConfettiSwiftUI

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: Int {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let rotation = CGFloat(Angle.degrees(5 * sin(Double(shakes) * 2 * .pi)).radians)
        return ProjectionTransform(CGAffineTransform(rotationAngle: rotation))
    }
}

struct TriviaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        entity: myWord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
        animation: .default
    )
    private var words: FetchedResults<myWord>

    @StateObject private var viewModel = TriviaViewModel()

    @State private var counter: Int = 0
    @State private var rotationAngle: Double = 0.0

    var body: some View {

        ZStack {

            Color.appBackground

            VStack {
                Text("Trivia")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                if words.count < 2 {
                    Spacer()
                    Text("Save at least 2 words to play Trivia.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.appPrimary)
                    }
                    .padding()

                } else if !viewModel.gameEnded {
                    Text("Question \(viewModel.currentQuestion) of \(viewModel.questionsPerGame)")
                        .font(.title2)
                        .padding()

                    Text("Score: \(viewModel.score)")

                    Text("Whats means \(words[viewModel.randomIndexP1].value ?? "No value")")
                        .font(.title2)
                        .padding()

                    VStack {
                        if viewModel.randomIndexResponse == 0 {

                            Text(words[viewModel.randomIndexP1].translation ?? "No translation")
                                .onTapGesture {
                                    viewModel.isCorrect = true
                                    viewModel.checkAnswer(words: Array(words))
                                    counter += 1
                                    viewModel.doSomethingAfter30Seconds(words: Array(words))
                                }
                                .padding()
                                .background(viewModel.isCorrect ? Color.appPrimary.opacity(0.7) : Color.appSurface)
                                .foregroundColor(viewModel.isCorrect ? Color.onPrimary : Color.onBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))

                            Text(words[viewModel.randomIndexP2].translation ?? "No translation")
                                .onTapGesture {
                                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                                        viewModel.isNotCorrect = true
                                        viewModel.doSomethingAfter30Seconds(words: Array(words))
                                    }
                                }
                                .padding()
                                .background(viewModel.isNotCorrect ? Color.red.opacity(0.7) : Color.appSurface)
                                .foregroundColor(viewModel.isCorrect ? Color.onPrimary : Color.onBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .modifier(ShakeEffect(shakes: viewModel.isNotCorrect ? 3 : 0))

                        } else {

                            Text(words[viewModel.randomIndexP2].translation ?? "No translation")
                                .onTapGesture {
                                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                                        viewModel.isNotCorrect = true
                                        viewModel.doSomethingAfter30Seconds(words: Array(words))
                                    }
                                }
                                .padding()
                                .background(viewModel.isNotCorrect ? Color.red.opacity(0.7) : Color.appSurface)
                                .foregroundColor(viewModel.isCorrect ? Color.onPrimary : Color.onBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .modifier(ShakeEffect(shakes: viewModel.isNotCorrect ? 3 : 0))

                            Text(words[viewModel.randomIndexP1].translation ?? "No translation")
                                .onTapGesture {
                                    viewModel.isCorrect = true
                                    viewModel.checkAnswer(words: Array(words))
                                    counter += 1
                                    viewModel.doSomethingAfter30Seconds(words: Array(words))
                                }
                                .padding()
                                .background(viewModel.isCorrect ? Color.appPrimary.opacity(0.7) : Color.appSurface)
                                .foregroundColor(viewModel.isCorrect ? Color.onPrimary : Color.onBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .confettiCannon(counter: $counter)
                    .frame(maxWidth: .infinity)

                    Button("Skip question") {
                        viewModel.updateRandomIndex(words: Array(words))
                        withAnimation(.spring()) {
                            rotationAngle += 360
                        }
                    }
                    .padding()

                    Button { dismiss() } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.appPrimary)
                    }
                    .padding()

                } else {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    Text("Final Score: \(viewModel.score)")
                        .font(.title2)
                        .padding()
                }
            }
            .onAppear {
                viewModel.startGame(words: Array(words))
                viewModel.updateRandomIndex(words: Array(words))
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.gray, radius: 4, x: 0, y: 2)
            .padding()
            .rotationEffect(.degrees(rotationAngle))
        }
    }
}

//
//  TriviaViewModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2026-05-20.
//

import Foundation
import CoreData

@MainActor
class TriviaViewModel: ObservableObject {

    @Published var score = 0
    @Published var currentQuestion = 1
    @Published var currentWords: [myWord] = []
    @Published var currentAnswer = ""
    @Published var gameEnded = false
    @Published var questionsPerGame: Int = 0
    @Published var randomIndexP1: Int = 0
    @Published var randomIndexP2: Int = 0
    @Published var randomIndexResponse: Int = 0
    @Published var isCorrect: Bool = false
    @Published var isNotCorrect: Bool = false

    func startGame(words: [myWord]) {
        currentWords = Array(words.shuffled().prefix(2))
        currentQuestion = 1
        score = 0
        gameEnded = false
        questionsPerGame = words.count
    }

    func updateRandomIndex(words: [myWord]) {
        guard !words.isEmpty else { return }
        randomIndexP1 = Int.random(in: 0..<words.count)
        randomIndexP2 = Int.random(in: 0..<words.count)
        while (randomIndexP2 - randomIndexP1) == 0 {
            randomIndexP2 = Int.random(in: 0..<words.count)
        }
        randomIndexResponse = Int.random(in: 0..<2)
    }

    func checkAnswer(words: [myWord]) {
        score += 1
        currentQuestion += 1
        if currentQuestion > questionsPerGame {
            gameEnded = true
        } else {
            currentWords = Array(words.shuffled().prefix(2))
        }
    }

    func doSomethingAfter30Seconds(words: [myWord]) {
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            updateRandomIndex(words: words)
            isCorrect = false
            isNotCorrect = false
        }
    }
}

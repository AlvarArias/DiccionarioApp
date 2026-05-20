//
//  QuizViewModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2026-05-20.
//

import Foundation
import CoreData

@MainActor
class QuizViewModel: ObservableObject {

    @Published var randomIndex: Int = 0

    func updateRandomIndex(words: [myWord]) {
        guard !words.isEmpty else { return }
        randomIndex = Int.random(in: 0..<words.count)
    }
}

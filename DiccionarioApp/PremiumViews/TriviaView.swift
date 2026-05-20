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
    
    @State private var score = 0
    @State private var currentQuestion = 1
    @State private var currentWords: [myWord] = []
    @State private var currentAnswer = ""
    @State private var gameEnded = false
    
    @State var questionsPerGame : Int = 0
    
    @State private var randomIndexP1: Int = 0
    @State private var randomIndexP2: Int = 0
    @State private var randomIndexResponse: Int = 0
    
    
    private var shuffledWords: [myWord] {
        Array(words).shuffled() // Fetch words into an array and shuffle it
    }
    
    private func updateRandomIndex() {
        if !shuffledWords.isEmpty {
            randomIndexP1 = Int.random(in: 0..<shuffledWords.count)
            randomIndexP2 = Int.random(in: 0..<shuffledWords.count)
            
            while (randomIndexP2 - randomIndexP1) == 0 {
                randomIndexP2 = Int.random(in: 0..<shuffledWords.count)
            }
            
            randomIndexResponse = Int.random(in: 0..<2)
            print(randomIndexResponse)
           
        }
    }
    
    // Confetti
    @State private var counter: Int = 0
    @State private var isCorrect : Bool = false
    @State private var isNotCorrect : Bool = false

    @State private var isAnimated = false
    @State private var rotationAngle: Double = 0.0
    
    var body: some View {
        
        ZStack {
            
            Color.teal
                .opacity(0.5)
            
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
                            .foregroundColor(Color.orange)
                    }
                    .padding()
                } else if !gameEnded {
                    Text("Question \(currentQuestion) of \(questionsPerGame)")
                        .font(.title2)
                        .padding()

                    Text("Score: \(score)")

                    Text("Whats means \(words[randomIndexP1].value ?? "No value")")
                        .font(.title2)
                        .padding()
                    
                    // Presenta las 2 alternativas
                    VStack {
                        
                        if randomIndexResponse == 0 {
                            
                            // TODO: agregar animacion al color, mejorar el codigo, crear 2 botones de igual largo con el text, usar sombras
                            
                            Text(words[randomIndexP1].translation ?? "No translation")
                                .onTapGesture {
                                    print("correcto")
                                    isCorrect = true
                                    checkAnswer()
                                    //updateRandomIndex()
                                    counter += 1
                                    print("counter = \(counter)")
                                    doSomethingAfter30Seconds()
                                }
                                .padding()
                                .background(isCorrect == true ? Color.blue.opacity(0.7) : Color.white)
                                .foregroundColor(isCorrect == true ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            Text(words[randomIndexP2].translation ?? "No translation")
                                .onTapGesture {
                                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                                        print("respuesta errada")
                                        isNotCorrect = true
                                        doSomethingAfter30Seconds()
                                    }
                                }
                                .padding()
                                .background(isNotCorrect == true ? Color.red.opacity(0.7) : Color.white)
                                .foregroundColor(isCorrect == true ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .modifier(ShakeEffect(shakes: isNotCorrect ? 3 : 0))
                            
                        }
                        
                        else {
                            
                            Text(words[randomIndexP2].translation ?? "No translation")
                                .onTapGesture {
                                  
                                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                                        
                                        print("respuesta errada")
                                        isNotCorrect = true
                                        doSomethingAfter30Seconds()
                                    }
                                        
                                }
                                .padding()
                                .background(isNotCorrect == true ? Color.red.opacity(0.7) : Color.white)
                                .foregroundColor(isCorrect == true ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .modifier(ShakeEffect(shakes: isNotCorrect ? 3 : 0))
                            
                            Text(words[randomIndexP1].translation ?? "No translation")
                                .onTapGesture {
                                    print("correcto")
                                    isCorrect = true
                                    checkAnswer()
                                    counter += 1
                                    print("counter = \(counter)")
                                    doSomethingAfter30Seconds()
                                }
                                .padding()
                                .background(isCorrect == true ? Color.blue.opacity(0.7) : Color.white)
                                .foregroundColor(isCorrect == true ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                        }
                    }
                    .confettiCannon(counter: $counter)
                    .frame(maxWidth: .infinity)
                
                    
                    Button("Skip question") {
                        updateRandomIndex()
                        withAnimation(.spring()) {
                            rotationAngle += 360
                        }
                    }
                    .padding()
                    
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.orange)
                    }
                    .padding()
                    
                    
                    
                } else {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Final Score: \(score)")
                        .font(.title2)
                        .padding()
                }
            }
            .onAppear {
                startGame()
                updateRandomIndex()
                questionsPerGame = words.count
                
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.gray, radius: 4, x:0, y:2)
            .padding()
            .rotationEffect(.degrees(rotationAngle))
        
        }
        
    
    }
    private func startGame() {
        currentWords = Array(words.shuffled().prefix(2))
        currentQuestion = 1
        score = 0
        gameEnded = false
        
    }
    
    private func checkAnswer() {
       
            score += 1

        currentQuestion += 1
        
        
        if currentQuestion > questionsPerGame {
            gameEnded = true
        } else {
            currentWords = Array(words.shuffled().prefix(2))
        }
    }
    
    private func translationView(_ index: Int, _ onTapAction: @escaping () -> Void) -> some View {
        let translation = words[index].translation ?? "No translation"
        return Text(translation)
            .padding()
            .onTapGesture(perform: onTapAction)
    }
    
    func doSomethingAfter30Seconds() {
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            updateRandomIndex()
            isCorrect = false
            isNotCorrect = false
        }
    }
    
}

/*
 VStack {
 Text("What does \(words[randomIndexP1].value ?? "No value") mean?")
 .font(.title2)
 .padding()
 
 VStack {
 if randomIndexResponse == 0 {
 translationView(randomIndexP1) {
 print("correcto")
 checkAnswer()
 updateRandomIndex()
 }
 
 //Spacer()
 
 translationView(randomIndexP2) {
 print("respuesta errada")
 }
 } else {
 translationView(randomIndexP2) {
 print("respuesta errada")
 }
 
 //Spacer()
 
 translationView(randomIndexP1) {
 print("correcto")
 checkAnswer()
 updateRandomIndex()
 }
 }
 }
 }
 .onAppear {
 updateRandomIndex()
 }
 */

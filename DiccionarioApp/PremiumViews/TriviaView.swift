//
//  TriviaView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-26.
//

import SwiftUI
import CoreData
import ConfettiSwiftUI

struct TriviaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
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

    var body: some View {
        VStack {
            Text("Trivia")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if !gameEnded {
                Text("Question \(currentQuestion) of \(questionsPerGame)")
                    .font(.title2)
                    .padding()
                
                Text("Score: \(score)")
                
                Text("Whats means \(words[randomIndexP1].value ?? "No value")")
                    .font(.title2)
                    .padding()
            
                VStack {
                    
                    if randomIndexResponse == 0 {
                     
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
                            .background(isCorrect == true ? Color.blue : Color.white)
                            .cornerRadius(15)
                            
                        
                        Text(words[randomIndexP2].translation ?? "No translation")
                            .onTapGesture {
                                print("respuesta errada")
                                isNotCorrect = true
                                doSomethingAfter30Seconds()
                            }
                            .padding()
                            .background(isNotCorrect == true ? Color.red : Color.white)
                            .cornerRadius(15)
                    }
                 
                    else {
                     
                            Text(words[randomIndexP2].translation ?? "No translation")
                                .onTapGesture {
                                    print("respuesta errada")
                                    isNotCorrect = true
                                    doSomethingAfter30Seconds()
                                }
                                .padding()
                                .background(isNotCorrect == true ? Color.red : Color.white)
                                .cornerRadius(15)
                        
                            
                            Text(words[randomIndexP1].translation ?? "No translation")
                                .onTapGesture {
                                    print("correcto")
                                    isCorrect = true
                                    checkAnswer()
                                    counter += 1
                                    print("counter = \(counter)")
                                    doSomethingAfter30Seconds()
                                }
                                //.confettiCannon(counter: $counter)
                                .padding()
                                .background(isCorrect == true ? Color.blue : Color.white)
                                .cornerRadius(15)
                        
                    }
                }
                .confettiCannon(counter: $counter)
                
                
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
                
                Button("Next question") {
                   updateRandomIndex()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Code to be executed after 30 seconds goes here
            updateRandomIndex()
            isCorrect = false
            isNotCorrect = false
        }
    }
    
}

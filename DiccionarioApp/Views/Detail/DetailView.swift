//
//  DetailView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

import AVFoundation
import CoreData

struct DetailView: View {
    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    // MARK: ObsObjects
    @ObservedObject var player = PlayerWord()
    
    // MARK: Core Data
    @Environment(\.managedObjectContext) var myNewWord

    // MARK: State
    @State private var isPlaying : Bool = false
    @State private var isSavedCData : Bool = false
    @State private var isDuplicateData : Bool = false
    
    @Binding var selectedLang: Bool
    
    // Create a speech synthesizer.
    let synthesizer = AVSpeechSynthesizer()
    
    let result : Result
    
    var body: some View {
            
       Form {
            
            WordInfoView(result: result, saveWordToCoreData: {
                saveWordToCoreData()
            })
            
           
               LanguageInfoView(result: result, selectedLang: selectedLang)
           
           if selectedLang {
               AudioPlaybackView(player: player, phonetic: result.baseLang?.phonetic)
           }
           
           /*
           Button {
               print("click paper plane")
              //textToSpeech(word: result.value ?? "No value")
               //textToSpeech(word: "Hola")
               
           } label: {
               Image(systemName: "paperplane")
           }
           */
           
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
                        if isSavedCData {
                            NotificationCore(text:LocalizedStringKey("saving"))
                                .transition(.move(edge: .top))
                        }
                        
                        if isDuplicateData {
                            NotificationCore(text:"The word already saved")
                                .transition(.move(edge: .top))
                        }
  
                    }
                )
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }

    
    func saveWordToCoreData() {
      
        // Try to save in Core Data
        let fetchRequest: NSFetchRequest<myWord> = myWord.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "value == %@", result.value ?? "")
        
        do {
            let existingWords = try myNewWord.fetch(fetchRequest)
            
            if existingWords.isEmpty {
                let theSelectedWord = myWord(context: myNewWord)
                // Fix values
                theSelectedWord.value = result.value ?? "No value"
                theSelectedWord.type = result.type ?? "No type"
                theSelectedWord.phonetic = result.baseLang?.phonetic?.content ?? ""
                theSelectedWord.file = result.baseLang?.phonetic?.file ?? ""
                
                // Selected language
                if selectedLang {
                    theSelectedWord.translation = result.targetLang?.translation ?? "No translation"
                    theSelectedWord.synonym = result.targetLang?.synonym?.first ?? ""
                } else {
                    theSelectedWord.meaning = result.baseLang?.meaning ?? "No meaning"
                }
                
                try myNewWord.save()
                showNotifCoreData()
            } else {
                print("Word already exists in Core Data")
                showNotifDuplicateData()
            }
        } catch {
            print("Error saving the word to Core Data: \(error)")
        }
    }

    
    
    func showNotifCoreData() {
        isSavedCData = true
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation {
                isSavedCData = false
            }
        }
    }

    func showNotifDuplicateData() {
        isDuplicateData = true
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation {
                isDuplicateData = false
            }
        }
    }
    
    
    
    func textToSpeech(word: String){
        
        
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: word)
   
        // Configure the utterance.
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.1
        
        // Retrieve the preferred voice.
        //let voice = AVSpeechSynthesisVoice(language: "en-US")
        let voice = AVSpeechSynthesisVoice(language: "es-MX")
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Speak the utterance.
        synthesizer.speak(utterance)
        
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



/*
func saveWordToCoreData() {
     
     // Try to save in Core Data
        let theSelectedWord = myWord(context: myNewWord)
        // Fix values
    theSelectedWord.value = result.value ?? "No value"
    theSelectedWord.type = result.type ?? "No type"
    
    theSelectedWord.phonetic = result.baseLang?.phonetic?.content ?? ""
    theSelectedWord.file = result.baseLang?.phonetic?.file ?? ""
       
        // Selected language
        if selectedLang {
            
            theSelectedWord.translation = result.targetLang?.translation ?? "No translation"
            theSelectedWord.synonym = result.targetLang?.synonym?.first ?? ""
            
        } else {
            
            theSelectedWord.meaning = result.baseLang?.meaning ?? "No meaning"
                
        }

    
    do {
           try myNewWord.save()
        
            showNotifCoreData()
           
       } catch {
           print("Error saving the word to Core Data: \(error)")
       }
    

    }
 */

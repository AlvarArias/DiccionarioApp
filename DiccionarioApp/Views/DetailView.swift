//
//  DetailView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct DetailView: View {
    
    // MARK: ObsObjects
    @ObservedObject var player = PlayerWord()
    
    // MARK: Core Data
    @Environment(\.managedObjectContext) var myNewWord

    // MARK: State
    @State private var isPlaying : Bool = false
    @StateObject private var wordListViewModel = WordListViewModel()
    @State private var newWord: String = ""
    
    @Binding var selectedLang: Bool
    
    let result : Result
    
    var body: some View {

            
            Form {
            
                HStack {
                    Text(result.value ?? "No value")
                        .font(.headline)
                        .listRowSeparator(.hidden)
                    
                    Text("(\(result.type ?? "No type"))")
                        .font(.subheadline)
                    
                    Spacer(minLength: 10)
                    
                    Button(action: {
                        newWord = result.value ?? "No value"
                        wordListViewModel.addWord(newWord)
                        
                        // Save to core data
                        saveWordToCoreData()
                      
                    }) {
                        Image(systemName: "plus")
                    }
                        
                }
                
                if selectedLang {
 
                    HStack {
                        
                        Text(result.targetLang?.translation ?? "no translation")
                    }
                    
                    HStack {
                 
                        Text(result.targetLang?.synonym?.first ?? "")
                          
                    }
                       
                } else {
                        
                    HStack {
                            
                            Text(result.baseLang?.meaning ?? "no translation")
                            
                        }
                    
                    HStack {
                 
                        Text(result.baseLang?.inflection?[0].content ?? "")
                        
                        Spacer(minLength: 5)
                        
                        Text(result.baseLang?.inflection?[1].content ?? "")
                          
                    }
                    
                    
                    }
                        
               
                
                HStack {
                    
                    Text(result.baseLang?.phonetic?.content ?? "Not file")
                       
                    Spacer(minLength: 10)
                    
                    Button {
                        isPlaying.toggle()
                        print("isPlaying \(isPlaying)")
                      
                        player.play(url: result.baseLang?.phonetic?.file ?? "Not file", state: isPlaying)

                    } label: {
                        
                        isPlaying == true ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                        
                    }.foregroundColor(Color.orange)
                     .onChange(of: player.playerStopped) { stopped in
                            if stopped {
                                print("stop")
                                isPlaying = false
                            }
                        }
                    
                    
                    }
            
    
            }
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
            

    }
    
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

            try? myNewWord.save()
  
        }
    
}



struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(player: PlayerWord(), selectedLang: .constant(false), result: .init(variantID: "variantID", value: "value", type: "type", baseLang: BaseLang(phonetic: Phonetic(file: "file", content: "content"), inflection: [Inflection(content: "content")], meaning: "meaning", illustration: [Illustration(type: "type", value: "value")], comment: "comment"), targetLang: TargetLang(translation: "translation", synonym: ["synonym"], comment: "comment")))
    }
}




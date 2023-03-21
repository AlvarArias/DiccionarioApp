//
//  DetailView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct DetailView: View {

    @ObservedObject var player = PlayerWord()

    let result : Result
    let fixURL = "https://www.thesprucepets.com/thmb/XMb-I4hzef2SyFGabzAPi0WnUJ0=/3000x0/filters:no_upscale():strip_icc()/smartest-cat-breeds-4589754-hero-e192f849d9f1442481c47c932cd36aa8.jpg"

    @State private var isPlaying : Bool = false
    
    
    @StateObject private var wordListViewModel = WordListViewModel()
    @State private var newWord: String = ""
    
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
                      
                    }) {
                        Image(systemName: "plus")
                    }
                        
                }
                
             

                HStack {
           
                    Text(result.targetLang?.translation ?? "no translation")
                       
                }
                
                HStack {
           
                    Text(result.baseLang?.meaning ?? "no translation")
                       
                }
                
                HStack {
             
                    Text(result.targetLang?.synonym?.first ?? "")
                      
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
    
      
}



struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(player: PlayerWord(), result: .init(variantID: "variantID", value: "value", type: "type", baseLang: BaseLang(phonetic: Phonetic(file: "file", content: "content"), inflection: [Inflection(content: "content")], meaning: "meaning", illustration: [Illustration(type: "type", value: "value")], comment: "comment"), targetLang: TargetLang(translation: "translation", synonym: ["synonym"], comment: "comment")))
    }
}




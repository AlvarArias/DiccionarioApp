//
//  WordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct WordView: View {

    // MARK: ObsObjects
    @ObservedObject var myviewModelWord = WordViewModel()
    
    // MARK: State
    @State private var text = ""
    @State private var selectedLang = true
    @State private var errorMessage: String = ""
    @State private var showProgressBarr = false
    
    @State private var showHistory = false
    @State private var showSavedWord = false
    @State private var showQuiz = false
    
    @State private var isVStackVisible = false
    
    
    @State private var newWord: String = ""
    @State var searchWords: [String] = [String]()
    
    /*
    @State private var selectedLang = true
    @State private var errorMessage = ""
    @State private var showProgressBar = false
    */
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                // Selection Lang View
                LanguageSelectionView(selectedLang: $selectedLang, errorMessage: $errorMessage, showProgressBar: $showProgressBarr, myviewModelWord: myviewModelWord)
                
                // Search Bar
                SearchBarView(text: $text, searchWords: $searchWords, showProgressBar: $showProgressBarr, myviewModelWord: myviewModelWord, selectedLang: selectedLang)
                
                // New List Search
                ScrollView {
                    
                    if showProgressBarr {
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                            
                    }
                    

                    
                    if errorMessage == "OK" {
                        
        
                        VStack(alignment: .leading) {
                            ForEach(myviewModelWord.results, id: \.self) { result in
                                NavigationLink(destination: DetailView(selectedLang: $selectedLang, result: result)) {
                                    
                                    
                                    VStack (alignment: .leading) {
                                        HStack {
                                            Text(result.value ?? "No value")
                                                .font(.headline)
                                            Spacer()
                                            
                                            Text(result.type ?? "No type")
                                                .font(.subheadline)
                                        }
                                        .padding(5)
                                        
                                        if selectedLang {
                                            
                                            VStack {
                                                Text(result.targetLang?.translation ?? "no translation").font(.caption)
                                                
                                            }
                                            
                                            
                                        } else {
                                            VStack {
                                                Text(result.baseLang?.meaning ?? "No meaning").font(.caption)
                                            }
                                        }
                                        
                                        
                                    }
                                    .padding(15)
                                    .background(Color(UIColor.white).opacity(0.9))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .foregroundColor(Color.black)
                                    .shadow(color: .gray, radius: 0.5, x: 0.5, y: -0.5)
                                    
                                }
                            }
                        }
                        .opacity(isVStackVisible ? 1.0 : 0.0)  // Set opacity based
                        .animation(.easeIn(duration: 1.0), value: isVStackVisible) // Add animation based on isVStackVisible state
                        .onAppear {
                            withAnimation {
                                isVStackVisible = true
                            }
                            showProgressBarr = false
                        }
                    }
                   
                }
                
            }

            .navigationTitle("Diccionary")
            .navigationBarTitleDisplayMode(.inline)
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
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                
                
                Button { showHistory.toggle()
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(Color.orange)
                }
                .sheet(isPresented: $showHistory) {
                    
                    FavoriteView( searchWors: $searchWords)
                        
                        
                }
                .frame(maxHeight: 300)
                
            // MARK: Quiz View
                
                Spacer()
            
                Button { showQuiz.toggle()
                } label: {
                    Image(systemName: "star")
                        .foregroundColor(Color.orange)
                }
                .sheet(isPresented: $showQuiz) {
                    
                    QuizView()
                    
                }
            
                
                Spacer()
                
                Button { showSavedWord.toggle()
                } label: {
                    Image(systemName: "checklist.checked")
                        .foregroundColor(Color.orange)
                }
                .sheet(isPresented: $showSavedWord) {
                    
                    SavedWordView()
                        
                }
                
  
            }
        }
    }
}

struct WordView_Previews: PreviewProvider {
    static var previews: some View {
        WordView()
    }
}

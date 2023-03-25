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
    @State private var showHistory = false
    @State private var showSavedWord = false
    @State private var showQuiz = false
    @State private var errorMessage: String = ""
    
    @State private var newWord: String = ""
    @State var searchWords: [String] = [String]()
    
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                // Setting Language Card
                VStack (alignment: .leading) {
                    Toggle("Select Language", isOn: $selectedLang)
                        .tint(.orange).opacity(0.7)
                    
                    // Select Text and Mje
                    HStack {
                        Text(selectedLang == true ? "SWE -> SPA" : "SPA -> SWE")
                            .listRowSeparator(.hidden)
                        
                        Text("\(errorMessage)")
                            .listRowSeparator(.hidden)
                            .onReceive(myviewModelWord.errorPublisher) { errorMessage in
                                self.errorMessage = errorMessage
                            }
                    }
                    
                    
                }
                .padding(10)
                .background(Color.blue.opacity(0.30))
                .cornerRadius(10)
                .padding()
                    
                // Search Bar
                HStack {
                    TextField("Search", text: $text)
                        .padding(.horizontal, 10)
                        .accentColor(.orange)
                        .accessibilityIdentifier("Search")
                    
                    Button {
                        print("Search")
                        if text != "" {
                            print(text)
                            myviewModelWord.fetchPosts(word: text, dir: selectedLang == true ? "to" : "from")
                            
                            newWord = text
                            searchWords.append(newWord)
                            
                        }
                        
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(UIColor.gray))
                    }
                    .accessibilityIdentifier("Button Search")
                
                    
                }
                .padding(15)
                .background(Color(UIColor.orange).opacity(0.4))
                .cornerRadius(10)
                .padding(.horizontal)
                
                
                // List Search
                Form {
                    
    
                    if errorMessage == "OK" {
                        
                        List( myviewModelWord.results, id: \.self) { resul in
                            
                            NavigationLink(destination: DetailView(selectedLang: $selectedLang, result: resul)) {
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text(resul.value ?? "No value")
                                            .font(.headline)
                                        Spacer()
                                        
                                        Text(resul.type ?? "No type")
                                            .font(.subheadline)
                                        
                                    }
                                    
                                    
                                    if selectedLang {
                                        
                                        Text(resul.targetLang?.translation ?? "no translation")
                                        
                                    } else {

                                        Text(resul.baseLang?.meaning ?? "No meaning")
                                    }
                                    
                      
                                }
                                .accessibilityIdentifier("link")
                            }
                            
                            
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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal, 10)
            Button {
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}


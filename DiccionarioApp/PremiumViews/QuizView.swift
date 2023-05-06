//
//  QuizView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI
import CoreData

struct QuizView: View {
    
    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: myWord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
        animation: .default
    )
    private var words: FetchedResults<myWord>
    
    @State private var randomIndex: Int = 0
    
    
    @State private var flipped = false
    
    @State private var rotationAngle: Double = 0.0
    
    var body: some View {
        //NavigationView {
          
        ZStack {
                
                Color.teal
                    .opacity(0.5)
            
            
            
            VStack {
   
                // Flascards
                VStack {
                    
                    Text("Cards").font(.title)
                        .padding()
                    
                    
                    VStack {
                        if flipped {
                            BackOfCardView(myTranslation: words[randomIndex].translation ?? "No translation")
                                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                        } else {
                            FrontOfCardView(myWord: words[randomIndex].value ?? "No word")
                                .id(words[randomIndex].value)
                                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                        }
                    }
                    .onTapGesture {
                        withAnimation (.easeInOut(duration: 0.5)) {
                            flipped.toggle()
                            rotationAngle += 360
                        }
                    }
                    .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                    .padding()
                    
                }
                
                Button("Next Card") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            rotationAngle += 360
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                updateRandomIndex()
                                flipped = false
                            }
                        }
                    }
                   .padding()
                
                
                Spacer()
                
                Button { dismiss() } label: {
                    Image(systemName: "arrow.down")
                        .foregroundColor(Color.orange)
                }
                .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(color: Color.gray, radius: 4, x:0, y:2)
            .padding()
        }
        
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
    
    func updateRandomIndex() {
        
        print("updateRandomIndex() \(words.count)")
        print("updateRandomIndex \(randomIndex)")
        
        if !words.isEmpty {
            randomIndex = Int.random(in: 0..<words.count)
            print("new randomIdex \(randomIndex)")
            
        }
    }
    
    
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}

struct FrontOfCardView: View {
    
    @State var myWord : String
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5)
            Text(myWord)
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 300)
        .cornerRadius(20)
        .shadow(color: Color.gray, radius: 1, x:0, y:2)
    }
}

struct BackOfCardView: View {
    
    @State var myTranslation : String
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.5)
            Text(myTranslation)
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 300)
        .cornerRadius(20)
        .shadow(color: Color.gray, radius: 1, x:0, y:2)
    }
}


/*
List {
    
    if !words.isEmpty {
        Text(words[randomIndex].value ?? "No value")
            .font(.headline)
        Text(words[randomIndex].type ?? "No type")
            .font(.subheadline)
        Text(words[randomIndex].translation ?? "no information")
            .font(.caption)
            .foregroundColor(.secondary)
    } else {
        Text("No words available.")
            .font(.headline)
    }
    
    Button("Next Question") {
        updateRandomIndex()
    }
    .padding()
}
.scrollContentBackground(.hidden)
.navigationTitle(LocalizedStringKey("quiz"))
.navigationBarTitleDisplayMode(.inline)
.onAppear(perform: updateRandomIndex)
.toolbar {
    ToolbarItemGroup(placement: .bottomBar) {
        Button { dismiss() } label: {
            Image(systemName: "arrow.down")
                .foregroundColor(Color.orange)
        }
        
    }
    
}
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
*/

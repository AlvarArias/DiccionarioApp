//
//  DetailView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI

struct DetailView: View {
    
    let result : Result
    let fixURL = "https://www.thesprucepets.com/thmb/XMb-I4hzef2SyFGabzAPi0WnUJ0=/3000x0/filters:no_upscale():strip_icc()/smartest-cat-breeds-4589754-hero-e192f849d9f1442481c47c932cd36aa8.jpg"
    
    var body: some View {
        
        ScrollView {
            
            ScrollView (){
                
                HStack {
                    Text(result.value ?? "No value")
                        .font(.headline)
                        .padding()
                       
                    Spacer(minLength: 10)
                    
                    Text(result.type ?? "No type")
                        .font(.subheadline)
                        .padding()
                        /*
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 80, height: 30)
                                .padding()
                        )
                        */
                        
                }
                
                Text("Tanslation")
                Text(result.targetLang?.translation ?? "no translation")
                    .padding()
                /*
                Text("Meaning")
                Text(result.baseLang?.meaning ?? "No meaning")
                    .padding()
                */
                
                Text("File")
                Text(result.baseLang?.phonetic?.file ?? "Not file")
                Text(result.baseLang?.phonetic?.content ?? "Not file")
                    .padding()
                
                Text("Synonimo")
                Text(result.targetLang?.synonym?.first ?? "Not file")
                    .padding()
                
                
                
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(UIColor(red: 0.45, green: 0.92, blue: 0.84, alpha: 1.00)),
                            Color(UIColor(red: 0.67, green: 0.71, blue: 0.90, alpha: 1.00))
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(result: .init(variantID: "variantID", value: "value", type: "type", baseLang: BaseLang(phonetic: Phonetic(file: "file", content: "content"), inflection: [Inflection(content: "content")], meaning: "meaning", illustration: [Illustration(type: "type", value: "value")], comment: "comment"), targetLang: TargetLang(translation: "translation", synonym: ["synonym"], comment: "comment")))
    }
}

/*
Text(result.baseLang?.illustration?[0].type ?? "Type")
Text(result.baseLang?.illustration?[0].value ?? "Value")

    AsyncImage(url: URL(string: result.baseLang?.illustration?[0].value ?? fixURL))
        .frame(width: 200, height: 200)
        .background(Color.orange)

    */
     
/*
List (result.baseLang?.illustration ?? [Illustration(type: "type", value: "value")], id: \.self) { ilust in
    Text(ilust.value ?? "Value")
    //Text(ilust.type ?? "Type")

}
 */

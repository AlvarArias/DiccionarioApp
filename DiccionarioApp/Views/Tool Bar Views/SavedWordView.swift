//
//  SavedWordView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI

struct SavedWordView: View {
    
    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    // MARK: CORE DATA
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(entity: myWord.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \myWord.value, ascending: true)],
                     animation: .default)
    
    // MARK: PUBLIC CLASS
    private var words: FetchedResults<myWord>
    
    
    @State private var deletedItems: [myWord] = []
    @State private var editMode: EditMode = .inactive
    
    private func deleteItems(offsets: IndexSet) {
        offsets.forEach { index in
            let item = words[index]
            deletedItems.append(item)
            viewContext.delete(item)
        }
        
        saveContext()
    }
    
    private func undeleteLastItem() {
        if let lastDeletedItem = deletedItems.popLast() {
            let restoredItem = myWord(context: viewContext)
            restoredItem.value = lastDeletedItem.value
            restoredItem.type = lastDeletedItem.type
            restoredItem.translation = lastDeletedItem.translation
            
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        }
    }

    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(words) { word in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(word.value ?? "No value")
                                .font(.headline)
                            Text(word.type ?? "No type")
                               
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        HStack{
                            Text(word.translation ?? "")
                                .font(.subheadline)
                                
                            Text(word.meaning ?? "")
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .environment(\.editMode, $editMode)
            .scrollContentBackground(.hidden)
            .navigationTitle(LocalizedStringKey("savedwords"))
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                /*
                Button(action: undeleteLastItem) {
                    Image(systemName: "arrow.uturn.left")
                }
                */
            
                                    
                Button(action: { editMode = editMode == .active ? .inactive : .active }) {
                    Image(systemName: "square.and.pencil")
                    .foregroundColor(Color.orange)
                    
                }
                
            }
            
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
            
        }
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

struct SavedWordView_Previews: PreviewProvider {
    static var previews: some View {
        SavedWordView()
    }
}



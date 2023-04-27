//
//  DiccionarioAppApp.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI
import CoreData
import SwiftUI
import RevenueCat



@main
struct DiccionarioAppApp: App {
    
    @StateObject private var appEnvironment = AppEnvironment()
    
    @StateObject private var dataController = DataController()
    
    @StateObject var userViewModel = UserViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            WordView()
            //PayWallContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(appEnvironment)
        }
    }
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_JIrdAvEzVUZttIBqoWRWAsoHxin")
    }
    
}

//
//  DiccionarioAppApp.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import SwiftUI
import CoreData
import SwiftUI

@main
struct DiccionarioAppApp: App {
    
    @StateObject private var appEnvironment = AppEnvironment()
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            //WordView()
            SplashView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(appEnvironment)
        }
    }
}

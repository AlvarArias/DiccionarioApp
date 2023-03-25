//
//  AppEnv.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

//import Foundation
import Combine
import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var currentLanguage: String = "en" {
        didSet {
            objectWillChange.send()
        }
    }
}


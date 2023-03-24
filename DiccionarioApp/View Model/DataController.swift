//
//  DataController.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import Foundation
import CoreData
import SwiftUI

import CoreData

public class Word: NSManagedObject, Identifiable {
    
    @NSManaged public var value: String
    @NSManaged public var type: String
    @NSManaged public var translation: String
    @NSManaged public var phonetic: String
    @NSManaged public var file: String
    @NSManaged public var synonym: String
    @NSManaged public var meaning: String
    
}


class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "WordModel")
    
    init () {
        container.loadPersistentStores { description, error in
                                        if let error = error {
            print("Core Data failed to load. \(error.localizedDescription)")
            }
        }
    }
}

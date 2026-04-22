//
//  UserViewModell.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-12-27.
//

import Foundation


@MainActor
class UserViewModel: ObservableObject {
    
    var isSubscriptionActive : Bool
    
    init(isSubscriptionActive: Bool) {
        self.isSubscriptionActive = isSubscriptionActive
    }
}

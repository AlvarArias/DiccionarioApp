//
//  ConfettiView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-27.
//

import SwiftUI
import ConfettiSwiftUI

struct ConfettiView: View {
    
    @State private var counter: Int = 0
    
    var body: some View {
        Button("🎉") {
                    counter += 1
                }
        .confettiCannon(counter: $counter)

    }
}

#Preview {
    ConfettiView()
}

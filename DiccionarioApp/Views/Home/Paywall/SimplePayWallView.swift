//
//  SimplePayWallView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-27.
//

import SwiftUI
import RevenueCat

struct SimplePayWallView: View {
    
    @State var currentOffering: Offering?
    
    var body: some View {
        VStack {
            Text("SimplePayWallView")
                .onTapGesture {
                    
                    print("SimplePayWallView")
                    /*
                    if currentOffering != nil {
                     
                        print(currentOffering?.availablePackages as Any)
                        
                    }*/
                    checkIfIsActiv()
                     
                }

        }
  
    }
    
    func checkIfIsActiv() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["pro"]?.isActive == true {
                print("premium")
            }
        }
    }
    
}

struct SimplePayWallView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePayWallView()
    }
}

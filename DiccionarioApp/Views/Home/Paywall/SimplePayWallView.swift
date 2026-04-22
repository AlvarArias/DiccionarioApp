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
            
                    checkIfIsActiv()
                    //customerInfo()
                     
                }
            Text(currentOffering?.id ?? "no id")
            Text(currentOffering?.description ?? "no description")
            
            
            if currentOffering == nil {
                Text("Display the offerts")
            }
            
        }
  
    }
    
    func checkIfIsActiv() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            print("checkIfIsActiv()")
            if customerInfo?.entitlements.all["pro"]?.isActive == true {
                print("premium")
            } else {
                
                print("suscription is not active")
 
            }
        }
    }
    
    func customerInfo() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            print("Customer info")
            print(customerInfo ?? "no customer info")
        }
    }
    
}

#Preview {
    SimplePayWallView()
}

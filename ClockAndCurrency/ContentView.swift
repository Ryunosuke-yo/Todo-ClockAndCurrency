//
//  ContentView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import SwiftUI
import CoreData
import UserNotifications


struct ContentView: View {
   
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            TabView {
                CurrencyView()
                    .tabItem {
                        Image(systemName: "dollarsign")
                    }
                ClockView()
                    .tabItem {
                        Image(systemName: "clock")
                    }
                TodoView()
                    .tabItem {
                        Image(systemName: "checklist")
                            
                    }
            }
        }
    }
    
}


struct BlueDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(width: Layout.width.rawValue, height: 1)
            
    }
}

    

 


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

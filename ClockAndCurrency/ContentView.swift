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
                TodoView()
                    .tabItem {
                        Image(systemName: "checklist")
                            
                    }
            }
        }
    }
    
}

    

 


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

//
//  ContentView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import SwiftUI
import CoreData

struct ContentView: View {
   
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            TabView {
                TodoView()
                    .tabItem {
                        Image(systemName: "alarm")
                            
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

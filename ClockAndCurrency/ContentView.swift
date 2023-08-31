//
//  ContentView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import SwiftUI
import CoreData
import UserNotifications

let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    
    init() {
        UITabBar.appearance().backgroundColor = .appWhite
    }
    
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

struct BlueBar: View {
    var body: some View {
        Capsule()
            .foregroundColor(.accentColor)
            .frame(width: 70, height: 6)
            .padding(.top, 20)
    }
}






//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}


//
//  TodoViewModel.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import Foundation


extension TodoView {
    class TodoViewModel: ObservableObject {
        @Published var width: CGFloat = 340
        @Published var showAllTodos = false
        @Published var addTodoNotificationOn = false
        @Published var showAddTodo = false
        @Published var todovalue = ""
        @Published var dateToShowTodo = Date()
        @Published var dateForNotofication = Date()
        @Published var assignedDate = Date()
        
        
        func isTheSameDate(fDate: Date, sDate: Date)-> Bool {
            
            let fDateString = formatDate(date: fDate)
            let sDateString = formatDate(date: sDate)
            
            if(fDateString == sDateString) {
                return true
            } else {
                return false
            }
            
        }
        
        func formatDate(date: Date)-> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            return formatter.string(from: date)
        }
    }
}

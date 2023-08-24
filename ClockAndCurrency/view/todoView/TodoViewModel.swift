//
//  TodoViewModel.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import Foundation


extension TodoView {
    @MainActor class TodoViewModel: ObservableObject {
        @Published var showAllTodos = true
        @Published var addTodoNotificationOn = false
        @Published var showAddTodo = false
        @Published var todovalue = ""
        @Published var dateToShowTodo = Date()
        @Published var dateForNotofication = Date()
        @Published var assignedDate = Date()
        @Published var todoMode = TodoMode.add
        @Published var uuidToEdit: UUID? = nil
        
        
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
        
        func onTapPensil(todo: Todos) {
            todoMode = .edit
            uuidToEdit = todo.uuid
            showAddTodo = true
        }
        
        
        func resetEachValue() {
            todovalue = ""
            addTodoNotificationOn = false
            assignedDate = Date()
            dateForNotofication = Date()
        }
        
        func convertDateToBannerFormat()-> String {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: assignedDate)
        }
    }
}

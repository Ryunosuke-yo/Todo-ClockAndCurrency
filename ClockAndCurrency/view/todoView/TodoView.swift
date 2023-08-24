//
//  TodoView.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-21.
//

import SwiftUI

struct TodoView: View {
    @StateObject var viewModel = TodoViewModel()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: []) var todos : FetchedResults<Todos>

    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Todo")
                        .fontWeight(.bold)
                        .tracking(1)
                        .font(.system(size: 20))
                        .foregroundColor(.appBlack)
                    Spacer()
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(.appBlack)
                        .frame(width: 18, height: 18)
                        .onTapGesture {
                            viewModel.showAddTodo = true
                        }
                    
                }
                .frame(width: Layout.width.rawValue)
                .padding([.top], 10)
                
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 1)
                
                
                Toggle(isOn: $viewModel.showAllTodos) {
                    Text("Show all todos")
                        .fontWeight(.light)
                        .foregroundColor(.appBlack)
                    
                }
                .frame(width:Layout.width.rawValue)
                .padding([.top], 10)
                .tint(.accentColor)
                
                if(!viewModel.showAllTodos) {
                    DatePicker(
                        "",
                        selection: $viewModel.dateToShowTodo,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .padding([.top], 10)
                    .background(Color.appWhite)
                }
                
                if todos.count > 0 {
                    List {
                        
                        ForEach(todos, id: \.self) { todo in
                            switch viewModel.showAllTodos {
                            case true:
                                EachTodo(todo: todo, width: Layout.width.rawValue, onTapTodo: {
                                    onTapTodo(todo: todo)
                                }, onTapPensil: {
                                    viewModel.onTapPensil(todo: todo)
                                })
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.appWhite)
                            case false:
                                if let assingedDate = todo.assignedDate {
                                    if(viewModel.isTheSameDate(fDate: viewModel.dateToShowTodo, sDate: assingedDate)) {
                                        EachTodo(todo: todo, width: Layout.width.rawValue, onTapTodo: {
                                            onTapTodo(todo: todo)
                                        }, onTapPensil: {
                                            viewModel.onTapPensil(todo: todo)
                                        })
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.appWhite)
                                    }
                                }
                            }
                            
                            
                        }
                        
                        .onDelete(perform: onSwipeDelete)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.appWhite)
                }
                Spacer()
            }
          
            .sheet(isPresented: $viewModel.showAddTodo) {
                renderAddTodoView()
            }
    
        }}
    
    @ViewBuilder
    func renderAddTodoView ()-> some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            VStack {
                Capsule()
                    .foregroundColor(.accentColor)
                    .frame(width: 70, height: 6)
                
                AddTodoEachRowWrapper {
                    TextField("Add todo", text: $viewModel.todovalue)
                        .frame(width: Layout.width.rawValue)
                    BlueDivider()
                        .padding([.top], 10)
                }
                
                AddTodoEachRowWrapper {
                    DatePicker(selection: $viewModel.assignedDate, displayedComponents: [.date]) {
                        Text("Date")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .tracking(0.5)
                    }
                    .frame(width: Layout.width.rawValue)
                    .tint(.accentColor)
                    BlueDivider()
                        .padding([.top], 10)
                    
                }
                
                AddTodoEachRowWrapper {
                    Toggle(isOn: $viewModel.addTodoNotificationOn) {
                        Text("Notofication")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .tracking(0.5)
                        
                    }
                    .frame(width: Layout.width.rawValue)
                    .tint(.accentColor)
                    BlueDivider()
                        .padding([.top], 10)
                }
                if(viewModel.addTodoNotificationOn) {
                    AddTodoEachRowWrapper {
                        DatePicker(selection: $viewModel.dateForNotofication, displayedComponents: [.date, .hourAndMinute]) {
                            Text("Reminder")
                                .foregroundColor(.appBlack)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .tracking(0.5)
                        }
                        .frame(width: Layout.width.rawValue)
                        .tint(.accentColor)
                        BlueDivider()
                            .padding([.top], 10)
                    }
                }
                
                Button(action: pressAdd) {
                    HStack {
                        Text(viewModel.todoMode == .add ? "Add" : "update")
                            .foregroundColor(.appWhite)
                            .font(.system(size: 17))
                    }
                    .frame(width: 170, height: 40)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                    
                    
                }
                .padding([.top], 30)
                
                Spacer()
                
            }
            .padding([.top], 30)
        }
        .onAppear {
            if viewModel.todoMode == .edit {
                if let uuid = viewModel.uuidToEdit {
                    let todoToEdit = todos.first {
                        $0.uuid == uuid
                    }
                    
                    if let selectedTodo = todoToEdit {
                        viewModel.todovalue = selectedTodo.todoValue ?? "unknown"
                        viewModel.addTodoNotificationOn = selectedTodo.notofication
                        viewModel.assignedDate = selectedTodo.assignedDate ?? Date()
                        viewModel.dateForNotofication = selectedTodo.notoficationTime ?? Date()
                    }
                }
                
                
            }
            
            
        }
        .onDisappear {
            viewModel.resetEachValue()
            viewModel.todoMode = .add
        }
    }
    
    
    func pressAdd() -> Void {
        if(viewModel.todovalue == "") {
            return
        }
        
        
        var currentUUID = UUID()
        if viewModel.todoMode == .add {
            let newTodo = Todos(context: managedObjectContext)
            newTodo.todoValue = viewModel.todovalue
            newTodo.assignedDate = viewModel.assignedDate
            newTodo.notofication = viewModel.addTodoNotificationOn
            newTodo.notoficationTime = viewModel.dateForNotofication
            newTodo.timestamp = Date()
            newTodo.completed = false
            newTodo.uuid = currentUUID
        } else if viewModel.todoMode == .edit {
            if let uuid = viewModel.uuidToEdit {
                let todoToEdit = todos.first {
                    $0.uuid == uuid
                }
                
                currentUUID = viewModel.uuidToEdit ?? UUID()
                
                if let selectedTodo = todoToEdit {
                    selectedTodo.todoValue = viewModel.todovalue
                    selectedTodo.notofication = viewModel.addTodoNotificationOn
                    selectedTodo.assignedDate = viewModel.assignedDate
                    selectedTodo.notoficationTime  = viewModel.dateForNotofication
                }
            }
            
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Today's Todo"
        content.subtitle = viewModel.todovalue
        content.sound = .default
        
        
        
        let calendar = Calendar.current
        let notifDate = calendar.dateComponents([.day, .month, .hour, .minute], from: viewModel.dateForNotofication)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notifDate , repeats: false)
        let request = UNNotificationRequest(identifier: currentUUID.uuidString , content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        viewModel.todoMode = .add
        viewModel.resetEachValue()
        PersistenceController.shared.save()
        
        viewModel.showAddTodo = false
        
        
    }
    
    func onSwipeDelete(indexSet: IndexSet) -> Void {
        
        for index in indexSet {
            let todoToDelete = todos[index]
            if let uuid = todoToDelete.uuid {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
            }
            
            managedObjectContext.delete(todoToDelete)
        }
        
        
        PersistenceController.shared.save()
    }
    
    func onTapTodo(todo: Todos)-> Void {
        for t in todos {
            if(t.uuid == todo.uuid) {
                t.completed.toggle()
            }
        }
        
        PersistenceController.shared.save()
    }
    
    
    
}
struct EachTodo: View {
    var todo : Todos
    var width: CGFloat
    var onTapTodo : ()-> Void
    var onTapPensil : ()-> Void
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: todo.completed ? "checkmark.circle" : "circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.accentColor)
                    Text(todo.todoValue ?? "Error")
                        .foregroundColor(todo.completed ? .accentColor : .appBlack)
                        .fontWeight(.bold)
                        .tracking(0.5)
                        .strikethrough(todo.completed, color: .accentColor)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onTapTodo()
                }
                
                
                if(todo.notofication) {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 18, height: 20)
                        .foregroundColor(.accentColor)
                        .padding([.trailing], 10)
                }
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        onTapPensil()
                    }
                
                
                
            }
            
            .frame(width: width)
            
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: width, height: 1)
        }
//        .padding([.vertical], 10)
//        .background(Color.appWhite)
    }
    
    
}

struct AddTodoEachRowWrapper<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder getContent: () -> Content) {
        self.content = getContent()
    }
    
    var body: some View {
        VStack(spacing:0) {
            content
        }
        .padding([.top], 30)
    }
    
    
}
struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView()
    }
}

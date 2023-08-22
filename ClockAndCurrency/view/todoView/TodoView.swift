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
            .frame(width: viewModel.width)
            .padding([.top], 10)
            
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 1)
            
            
            Toggle(isOn: $viewModel.showAllTodos) {
                Text("See all todos")
                    .fontWeight(.light)
                    .foregroundColor(.appBlack)
                
            }
            .frame(width: viewModel.width)
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
            }
            
            List {
                ForEach(todos, id: \.self) { todo in
                    
                    switch viewModel.showAllTodos {
                    case true:
                        EachTodo(todo: todo, width: viewModel.width) {
                            onTapTodo(todo: todo)
                        }
                        .listRowSeparator(.hidden)
                    case false:
                        if let assingedDate = todo.assignedDate {
                            if(viewModel.isTheSameDate(fDate: viewModel.dateToShowTodo, sDate: assingedDate)) {
                                EachTodo(todo: todo, width: viewModel.width) {
                                    onTapTodo(todo: todo)
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                    
                    
                }
                .onDelete(perform: onSwipeDelete)
                
                
                Spacer()
            }
            .scrollContentBackground(.hidden)
            
            
        }
        .sheet(isPresented: $viewModel.showAddTodo) {
            renderAddTodoView()
        }
        
        
    }
    
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
                        .frame(width: viewModel.width)
                    renderAddTodoDevider()
                }
                
                AddTodoEachRowWrapper {
                    DatePicker(selection: $viewModel.assignedDate, displayedComponents: [.date]) {
                        Text("Date")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .tracking(0.5)
                    }
                    .frame(width: viewModel.width)
                    .tint(.accentColor)
                    renderAddTodoDevider()
                }
                
                AddTodoEachRowWrapper {
                    Toggle(isOn: $viewModel.addTodoNotificationOn) {
                        Text("Notofication")
                            .foregroundColor(.appBlack)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .tracking(0.5)
                        
                    }
                    .frame(width: viewModel.width)
                    .tint(.accentColor)
                    renderAddTodoDevider()
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
                        .frame(width: viewModel.width)
                        .tint(.accentColor)
                        renderAddTodoDevider()
                    }
                }
                
                Button(action: pressAdd) {
                    HStack {
                        Text("Add")
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
            viewModel.todovalue = ""
            viewModel.addTodoNotificationOn = false
            viewModel.assignedDate = Date()
            viewModel.dateForNotofication = Date()
            
        }
    }
    
    @ViewBuilder
    func renderAddTodoDevider() -> some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(width: viewModel.width, height: 1)
            .padding([.top], 10)
    }
    
    func pressAdd() -> Void {
        if(viewModel.todovalue == "") {
            return
        }
        let newTodo = Todos(context: managedObjectContext)
        newTodo.todoValue = viewModel.todovalue
        newTodo.assignedDate = viewModel.assignedDate
        newTodo.notofication = viewModel.addTodoNotificationOn
        newTodo.notoficationTime = viewModel.dateForNotofication
        newTodo.timestamp = Date()
        newTodo.completed = false
        newTodo.uuid = UUID()
        
        PersistenceController.shared.save()
        
        viewModel.showAddTodo = false
        
        
    }
    
    func onSwipeDelete(indexSet: IndexSet) -> Void {
        for index in indexSet {
            let todoToDelete = todos[index]
            managedObjectContext.delete(todoToDelete)
        }
        
        PersistenceController.shared.save()
    }
    
    func onTapTodo(todo: Todos) {
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
                
                
            }
            
            .frame(width: width)
            
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: width, height: 1)
        }
        .padding([.vertical], 10)
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

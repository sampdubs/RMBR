//
//  ToDoList.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct ToDoList: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var todos: [ToDo] = []
    @State private var showSheet = false
    @State private var sheetType = "add"
    @State var showingToDo: ToDo?
    @State private var text: String = ""
    @State var update = true
    @Binding var showSetting: Bool
    var subList: String
    
    let db = Firestore.firestore()
    
    fileprivate func saveTodoSheet() {
        if (self.text.isEmpty) {
            return
        }
        
        let toSave: [String: Any] = [
            "text": self.text,
            "order": -1,
            "done": false
        ]
        
        db.collection("users/\(userID)/todos/sublists/\(self.subList)").addDocument(data: toSave)
    }
    
    fileprivate func assignOrder() {
        let batch = db.batch()
        for i in 0..<self.todos.count {
            let ref = db.document("users/\(userID)/todos/sublists/\(self.subList)/\(self.todos[i].id)")
            batch.updateData(["order": i], forDocument: ref)
        }
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            }
        }
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        self.todos.move(fromOffsets: source, toOffset: destination)
        self.assignOrder()
    }
    
    var body: some View {
        VStack {
            HStack() {
                Text("Add New To Do ")
                    .font(.headline)
                Button(action: {
                    self.assignOrder()
                    self.sheetType = "add"
                    self.showSheet.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }
            }
            if self.todos.count == 1 {
                Text("1 thing to do")
            } else {
                Text(String(self.todos.count) + " things to do")
            }
            List {
                ForEach(todos, id: \.id) { todo in
                    HStack {
                        Image(systemName: todo.done ? "checkmark.square" : "square")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(todo.done ? .green : self.colorScheme == .light ? .black : .white)
                            .gesture(TapGesture().onEnded(){
                                self.db.document("users/\(userID)/todos/sublists/\(self.subList)/\(todo.id)").setData(["done": !todo.done], merge: true)
                                self.update.toggle()
                                self.showSheet = false
                            })
                        Text(todo.text)
                            .frame(height: 35)
                            .foregroundColor(todo.done ? .gray : self.colorScheme == .light ? .black : .white)
                            .gesture(TapGesture().onEnded(){
                                self.text = todo.text
                                self.showSheet = true
                                self.sheetType = "show"
                                self.showingToDo = todo
                                self.assignOrder()
                                self.update.toggle()
                            })
                    }
                }
                .onDelete { IndexSet in
                    guard 0 < self.todos.count else { return }
                    self.db.document("users/\(userID)/todos/sublists/\(self.subList)/\(self.todos[IndexSet.first!].id)").delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        }
                    }
                    self.update.toggle()
                }
                .onMove(perform: move)
                if self.todos.count > 0 && self.todos.last!.done {
                    Button(action: {
                        let batch = self.db.batch()
                        for todo in self.todos {
                            if todo.done {
                                let doc = self.db.document("users/\(userID)/todos/sublists/\(self.subList)/\(todo.id)")
                                batch.deleteDocument(doc)
                            }
                        }
                        batch.commit() { err in
                            if let err = err {
                                print("Error writing batch \(err)")
                            }
                        }
                    }){
                        Text("Delete completed to-dos")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            .foregroundColor(.red)
                    }
                }
                Text(self.update ? "YES" : "NO")
                    .hidden()
            }
        }
        .navigationBarTitle(Text(self.subList))
        .sheet(isPresented: $showSheet, onDismiss: {
            if self.sheetType == "add" {
                self.saveTodoSheet()
            }
            self.text = ""
            self.assignOrder()
        }
        ) {
            if self.sheetType == "add" {
                AddToDo(text: self.$text)
            } else {
                ShowToDo(text: self.$text, toDo: self.$showingToDo, subList: self.subList)
            }
        }
        .onAppear {
            self.db.collection("users/\(userID)/todos/sublists/\(self.subList)")
                .addSnapshotListener { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.todos.removeAll()
                        for document in querySnapshot!.documents {
                            if document.data().count > 0 {
                                self.todos.append(ToDo(document.documentID, document.data()))
                            }
                        }
                        self.todos.sort {
                            if $0.done != $1.done {
                                return !$0.done
                            }
                            return $0.order < $1.order
                        }
                        self.assignOrder()
                        self.update.toggle()
                    }
            }
        }
    }
}

struct ToDoList_Previews: PreviewProvider {
    static var previews: some View {
        ToDoList(showSetting: .constant(false), subList: "Main List")
    }
}

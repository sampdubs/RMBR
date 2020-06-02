//
//  ToDoList.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFunctions

struct ToDoMain: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var isEditMode: EditMode = .inactive
    
    @State private var lists: Set<String> = []
    @State private var showSheet = false
    @State private var showAlert = false
    @State private var alertMessage = 0
    @State private var deletingList = ""
    @State private var text: String = ""
    @State private var replacing = ""
    @State var update = true
    @Binding var showSetting: Bool
    
    @EnvironmentObject var userID: UserID
    
    let db = Firestore.firestore()
    let functions = Functions.functions(region: "us-east1")
    
    fileprivate func saveTodoSheet() {
        if (self.text.isEmpty) {
            return
        }
        if (self.replacing != self.text && lists.contains(self.text)) {
            self.showAlert = true
            self.alertMessage = 1
        }
        if (self.replacing.count > 0) {
            self.functions.httpsCallable("renameCollection").call(["path": "users/\(userID.id)/todos/sublists/\(self.replacing)", "name": "self.text"]) { (result, err) in
                if let err = err {
                    print("error renaming subcollection: \(err)")
                } else {
                    print(result!.data)
                }
            }
        } else {
            db.collection("users/\(userID.id)/todos/sublists/\(self.text)").addDocument(data: [String:Any]()) { (err) in
                if let err = err {
                    print("error initializing sublist: \(err)")
                }
            }
        }
        lists.remove(self.replacing)
        lists.insert(self.text)
        UserDefaults.standard.set(self.lists.sorted(), forKey: "todoLists")
        self.replacing = ""
    }
    
    fileprivate func deleteList(_ list: String) {
        lists.remove(list)
        self.functions.httpsCallable("deleteCollection").call(["path": "users/\(userID.id)/todos/sublists/\(list)"]) { (result, err) in
            if let err = err {
                print("error getting subcollections: \(err)")
            } else {
                UserDefaults.standard.set(self.lists.sorted(), forKey: "todoLists")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Add New To Do List")
                        .font(.headline)
                    Button(action: {
                        self.showSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
                List {
                    ForEach(lists.sorted(), id: \.self) { list in
                        VStack {
                            if self.isEditMode == .inactive {
                                NavigationLink(destination: ToDoList(showSetting: self.$showSetting, subList: list)) {
                                    Text(list)
                                }
                            } else {
                                Button(action: {}) {
                                    Text(list)
                                        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                                }
                                    .contentShape(Rectangle())
                                .onTapGesture {
                                    self.replacing = list
                                    self.text = list
                                    self.showSheet = true
                                }
                            }
                        }
                    }
                    .onDelete { IndexSet in
                        guard 0 < self.lists.count else { return }
                        self.deletingList = self.lists.sorted()[IndexSet.first!]
                        self.alertMessage = 2
                        self.showAlert = true
                    }
                    Text(self.update ? "YES" : "NO")
                        .hidden()
                }
            }
            .navigationBarTitle("To Do Lists")
            .navigationBarItems(leading: SettingsButton(showSetting: self.$showSetting), trailing: EditButton())
            .environment(\.editMode, self.$isEditMode)
            .sheet(isPresented: $showSheet, onDismiss: {
                self.saveTodoSheet()
                self.text = ""
            }
            ) {
                AddToDoList(text: self.$text)
            }
            .alert(isPresented: self.$showAlert) {
                if self.alertMessage == 1 {
                    return Alert(title: Text("You already have a list with that name"), dismissButton: .default(Text("Okay")))
                }
                return Alert(title: Text("Are you sure you want to delete this list?"), message: Text("This action cannot be undone"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                    self.deleteList(self.deletingList)
                }))
            }
        }
        .onAppear {
            self.lists = Set(UserDefaults.standard.stringArray(forKey: "todoLists")!)
            self.functions.httpsCallable("getSubCollections").call(["path": "users/\(self.userID.id)/todos/sublists"]) { (result, err) in
                if let err = err {
                    print("error getting subcollections: \(err)")
                } else if let cols = (result?.data as? [String:Any])?["collections"] as? [String] {
                    self.lists = Set(cols)
                    UserDefaults.standard.set(cols, forKey: "todoLists")
                } else {
                    print("unable to retrieve collections")
                }
            }
        }
    }
}

struct ToDoMain_Previews: PreviewProvider {
    static var previews: some View {
        ToDoMain(showSetting: .constant(false))
    }
}

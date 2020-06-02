//
//  ShowToDo.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/16/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct ShowToDo: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var text: String
    @Binding var toDo: ToDo?
    @State private var edit = false
    @State private var update = false
    
    @EnvironmentObject var userID: UserID
    
    let db = Firestore.firestore()
    var subList: String
    
    fileprivate func saveTodoSheet() {
        if (self.text.isEmpty) {
            return
        }
        db.document("users/\(userID.id)/todos/\(self.toDo!.id)").setData(["text": self.text], merge: true)
        self.toDo!.text = self.text
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Button (action: {
                    self.toDo!.done.toggle()
                    self.db.document("users/\(self.userID.id)/todos/sublists/\(self.subList)/\(self.toDo!.id)").setData(["done": self.toDo!.done], merge: true)
                    self.update.toggle()
                }) {
                    Image(systemName: toDo!.done ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .foregroundColor(toDo!.done ? .green : self.colorScheme == .light ? .black : .white)
                }
                Text(self.toDo!.text)
                Text(self.update ? "YES" : "NO")
                    .hidden()
            }
            .navigationBarTitle(self.toDo!.text)
            .navigationBarItems(trailing: Button("Edit") {self.edit.toggle()})
        }
        .padding()
        .sheet(isPresented: self.$edit, onDismiss: self.saveTodoSheet) {
            AddToDo(text: self.$text)
        }
    }
}

struct ShowToDo_Previews: PreviewProvider {
    static var previews: some View {
        ShowToDo(text: .constant("Preview"), toDo: .constant(nil), subList: "Main List")
    }
}

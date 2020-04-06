//
//  ShowMemory.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import UIKit
import CoreData
import Firebase

public struct ShowMemory: View {
    @Binding var memory: Memory?
    @Binding var title: String
    @Binding var text: String
    @Binding var images: [UIImage]
    @State private var edit = false
    @State private var update = false
    
    let db = Firestore.firestore()
    
    fileprivate func saveMemSheet() {
        self.edit = false
        
        self.memory!.title = self.title
        self.memory!.text = self.text
        self.memory!.date = Date()
        self.memory!.attachments = self.images
        
        var imArray: [String] = []
        for image in self.images {
            if let str = image.toString() {
                imArray.append(str)
            }
        }
        
        let toSave: [String: Any] = [
            "title": self.title,
            "text": self.text,
            "date": Timestamp(date: Date()),
            "attachments": imArray
        ]
        
        db.document("users/user-id/memories/\(self.memory!.id)").setData(toSave)
        
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Text(self.memory!.text)
                List {
                    ForEach(0..<(self.memory!.attachments).count, id: \.id) { i in
                        Image(uiImage: self.memory!.attachments[i])
                            .resizable()
                            .aspectRatio(self.memory!.attachments[i].size.width/self.memory!.attachments[i].size.height, contentMode: .fit)
                            .cornerRadius(10)
                    }
                }
                Text(String(update))
                    .hidden()
            }
            .navigationBarTitle(self.memory!.title)
            .navigationBarItems(trailing: Button("Edit") {self.edit.toggle()})
        }
        .padding()
        .sheet(isPresented: self.$edit, onDismiss: self.saveMemSheet) {
            AddMemory(title: self.$title, text: self.$text, images: self.$images)
        }
    }
}

struct ShowMemory_Previews: PreviewProvider {
    static var previews: some View {
        ShowMemory(memory: .constant(nil), title: .constant("title"), text: .constant("text"), images: .constant([]))
    }
}

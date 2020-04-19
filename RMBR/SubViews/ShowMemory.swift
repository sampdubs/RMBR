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
import FirebaseStorage

public struct ShowMemory: View {
    @Binding var memory: Memory?
    @Binding var title: String
    @Binding var text: String
    @Binding var images: [UIImage]
    @State private var edit = false
    @State private var update = false
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    fileprivate func saveImages(_ ims: [UIImage], _ memID: String) {
        let storageRef = storage.reference()
        var urls: [String] = []
        for i in 0..<ims.count {
            let name = UUID().uuidString
            let data = ims[i].getData()
            let filename = getDocumentsDirectory().appendingPathComponent("\(name).png")
            do {
                try data.write(to: filename)
            } catch {
                print("file write failed")
            }
            let imageRef = storageRef.child("images/\(name)")
            imageRef.putData(data)
            urls.append(name)
        }
        self.addImageLinks(urls, memID)
    }
    
    fileprivate func addImageLinks(_ urls: [String], _ memID: String) {
        let docRef = db.document("users/\(userID)/memories/\(memID)")
        var currentIms: [String] = []
        docRef.getDocument { (document, err) in
            if let document = document, document.exists {
                currentIms = document.data()!["attachments"] as? [String] ?? []
                for i in 0..<urls.count {
                    for j in 0..<currentIms.count {
                        if currentIms[j].prefix(7) == "pending" && Int(currentIms[j].filter { "0"..."9" ~= $0 }) == i {
                            currentIms[j] = urls[i]
                            break
                        }
                    }
                    docRef.updateData(["attachments": currentIms])
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    fileprivate func saveMemSheet() {
        self.edit = false
        
        self.memory!.title = self.title
        self.memory!.text = self.text
        self.memory!.date = Date()
        self.memory!.attachments = self.images
        
        var imArray: [String] = []
        for i in 0..<self.images.count {
            imArray.append("pending\(i)")
        }
        
        let toSave: [String: Any] = [
            "title": self.title,
            "text": self.text,
            "date": Timestamp(date: Date()),
            "attachments": imArray
        ]
        
        db.document("users/\(userID)/memories/\(self.memory!.id)").setData(toSave)
        self.saveImages(self.images, self.memory!.id)
    }
    
    fileprivate func imageElement(_ pic: UIImage) -> some View {
        return VStack {
            if pic === loading {
                ActivityIndicator(style: .large)
            } else {
                Image(uiImage: pic)
                    .resizable()
                    .aspectRatio(pic.size.width/pic.size.height, contentMode: .fit)
                    .cornerRadius(10)
            }
        }
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Text(self.memory!.text)
                List {
                    ForEach(self.memory!.attachments, id: \.self) { pic in
                        self.imageElement(pic)
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
        ShowMemory(memory: .constant(Memory("id", [
            "title": "title",
            "text": "text",
            "date": Timestamp(date: Date()),
            "attachments": []
        ])), title: .constant("title"), text: .constant("text"), images: .constant([]))
    }
}

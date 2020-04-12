//
//  Memories.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct Memories: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme // Light or dark mode?

    @State private var memories: [Memory] = []
    @State private var showSheet = false
    @State private var sheetType = "add"
    @State private var showingMemory: Memory?
    @State private var images: [UIImage] = []
    @State private var title: String = ""
    @State private var text: String = ""
    @Binding var showSetting: Bool

    let db = Firestore.firestore()
    let storage = Storage.storage()

    fileprivate func memoryListElement(_ memory: Memory) -> some View {
        return //                         When the memory is clicked, grab its info
            Button (action: {
                self.title = memory.title
                self.text = memory.text
                //                            empty image arry
                self.images.removeAll()
                //                            add in all images for this memory
                for uiim in memory.attachments {
                    self.images.append(uiim)
                }
                self.showingMemory = memory
                self.sheetType = "show"
                self.showSheet = true
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(memory.title)
                            .bold()
                            .font(.headline)
                        Text(beautifyDate(memory.date))
                            .font(.caption)
                        Text(memory.text)
                    }
                    .frame(height: 70)
                    Spacer()
                    Text(attachmentsText(memory.attachments.count))
                }
        }
    }
    
    fileprivate func saveImages(_ ims: [UIImage], _ memID: String) {
        let storageRef = storage.reference()
        var urls: [String] = []
        for i in 0..<ims.count {
            let name = UUID().uuidString
            let data = ims[i].rotated()!.pngData()!
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
        if (self.title.isEmpty && self.text.isEmpty && self.images.isEmpty) {
            return
        }

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

        let docRef = db.collection("users/\(userID)/memories").addDocument(data: toSave)
        self.saveImages(self.images, docRef.documentID)
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .center, spacing: 25) {
                    Text("Add New Memory")
                        .font(.headline)
                    Button(action: {
                        self.sheetType = "add"
                        self.showSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
                if self.memories.count == 1 {
                    Text("1 memory")
                } else {
                    Text(String(self.memories.count) + " memories")
                }
                //                This list contains all of the memories
                List {
                    ForEach(memories) { memory in
                        self.memoryListElement(memory)
                    }.onDelete { IndexSet in
                        //                        make sure there are more than 0 memories
                        guard 0 < self.memories.count else { return }
                        let docRef = self.db.document("users/\(userID)/memories/\(self.memories[IndexSet.first!].id)")
                        var imageIDs: [String] = []
                        docRef.getDocument { (document, err) in
                            if let document = document, document.exists {
                                imageIDs = document.data()!["attachments"] as? [String] ?? []
                                docRef.delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        for id in imageIDs {
                                            self.storage.reference(withPath: "images/\(id)").delete { err in
                                                if let err = err {
                                                    print("error deleting from storage: \(err)")
                                                }
                                            }
                                            do {
                                                try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent("\(id).png"))
                                            } catch {
                                                print("error deleting file")
                                            }
                                        }
                                    }
                                }
                            } else {
                                print("doc does not exist")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Memories")
            .navigationBarItems(leading:
                Button(action: {
                    self.showSetting = true
                }){
                    Image(systemName: "line.horizontal.3")
            }, trailing: EditButton())
                .sheet(isPresented: self.$showSheet, onDismiss: {
                    //                When a sheet for adding a memory is swiped down, save it
                    if self.sheetType == "add" {
                        self.saveMemSheet()
                    }
                    self.title = ""
                    self.text = ""
                    self.images.removeAll()
                }
                ) {
                    //                passing on state to child views
                    if self.sheetType == "add" {
                        AddMemory(title: self.$title, text: self.$text, images: self.$images)

                    } else {
                        ShowMemory(memory: self.$showingMemory, title: self.$title, text: self.$text, images: self.$images)
                    }
            }
        }
        .onAppear {
            self.db.collection("users/\(userID)/memories")
                .addSnapshotListener { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.memories = []
                        for document in querySnapshot!.documents {
                            self.memories.append(Memory(document.documentID, document.data()))
                        }
                        self.memories.sort {
                            return $0.date > $1.date
                        }
                    }
                }
        }
    }
}

struct memories_Previews: PreviewProvider {
    static var previews: some View {
        Memories(showSetting: .constant(false))
    }
}


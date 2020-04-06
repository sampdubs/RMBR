//
//  AddMemory.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import UIKit

struct AddMemory: View {
    @State private var showImagePicker: Bool = false
    @State private var showImageChoice: Bool = false
    @State private var capture: Bool = false
    @State private var update: Bool = false
    @Binding var title: String
    @Binding var text: String
    @Binding var images: [UIImage]
    
    var body: some View {
        VStack {
            Text("Title:")
                .multilineTextAlignment(.leading)
            TextField("Title", text: $title)
                .font(Font.system(size: 30, design: .default))
            Text("Body:")
            TextView(text: $text)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(red: 0.8, green: 0.8, blue: 0.8)))
            HStack{
                Button(action: {
                    self.showImageChoice = true
                }) {
                    Text("Add image")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                List {
                    ForEach(0..<self.images.count, id: \.id) { i in
                        HStack {
                            Image(uiImage: self.images[i])
                                .resizable()
                                .aspectRatio(self.images[i].size.width/self.images[i].size.height, contentMode: .fit)
                                .cornerRadius(5)
                            Button(action: {
                                self.update.toggle()
                                self.images.remove(at: i)
                            }) {
                                Text("Remove Attachment")
                            }
                            .font(.footnote)
                        }
                        .frame(height: 50)
                    }
                    .onDelete { IndexSet in
                        guard 0 < self.images.count else { return }
                        self.images.remove(at: IndexSet.first!)
                        self.update.toggle()
                    }
                }
            }
            Text(String(update))
            .hidden()
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
        .actionSheet(isPresented: $showImageChoice) {
            ActionSheet(title: Text("Add Image"), buttons: [
                .default(Text("From Camera Roll")) {
                    self.capture = false
                    self.showImagePicker = true
                    self.showImageChoice = false
                },
                .default(Text("Take New Picture")) {
                    self.capture = true
                    self.showImagePicker = true
                    self.showImageChoice = false
                },
                .default(Text("Dismiss")) {
                    self.showImageChoice = false
                }
            ])
        }
        .sheet(isPresented: self.$showImagePicker) {
            PhotoCaptureView(showImagePicker: self.$showImagePicker, images: self.$images, capture: self.$capture)
        }
    }
}

struct AddMemory_Previews: PreviewProvider {
    static var previews: some View {
        AddMemory(title: .constant(""), text: .constant(""), images: .constant([]))
    }
}

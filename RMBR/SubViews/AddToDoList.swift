//
//  AddToDoList.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import UIKit

struct AddToDoList: View {
    @Binding var text: String
    
    var body: some View {
        VStack {
            Text("To Do List:")
            TextField("List Name", text: $text)
                .font(Font.system(size: 30, design: .default))
            Spacer()
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct AddToDoList_Previews: PreviewProvider {
    static var previews: some View {
        AddToDoList(text: .constant(""))
    }
}


//
//  AddMemory.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import UIKit

struct AddToDo: View {
    @Binding var text: String
    
    var body: some View {
        VStack {
            Text("To Do:")
            TextField("To Do", text: $text)
                .font(Font.system(size: 30, design: .default))
            Spacer()
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct AddToDo_Previews: PreviewProvider {
    static var previews: some View {
        AddToDo(text: .constant(""))
    }
}


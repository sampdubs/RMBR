//
//  MiniSignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 7/24/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct MiniSignIn: View {
    @EnvironmentObject var userID: UserID
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alertType = 0
    
    var body: some View {
        VStack {
            Spacer()
            Login(alertType: self.$alertType)
                .environmentObject(userID)
            GoogleScreen()
                .environmentObject(userID)
            Spacer()
        }
    }
}

struct MiniSignIn_Previews: PreviewProvider {
    static var previews: some View {
        MiniSignIn()
    }
}

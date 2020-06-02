//
//  SignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 5/7/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject var userID: UserID
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Spacer()
            Text("If you don't have an account, a new one will be created with your credentials when you log in.")
            Login()
                .environmentObject(userID)
            GoogleScreen()
                .environmentObject(userID)
            LoginView()
                .environmentObject(userID)
            Spacer()
        }
        .alert(isPresented: Binding<Bool>(
            get: {
                return self.userID.updated
        },
            set: { newVal in
                self.userID.updated = false
        }
        )) {
            Alert(title: Text("Signed in!"), dismissButton: .default(Text("Okay")) {
                self.presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
            .environmentObject(UserID())
    }
}

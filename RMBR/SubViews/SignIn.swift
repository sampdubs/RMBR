//
//  SignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 5/7/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct SignIn: View {
    @EnvironmentObject var userID: UserID
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingAlert = false
    @State private var alertType = 0
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("If you don't have an account, a new one will be created with your credentials when you log in.")
            Login(alertType: self.$alertType)
                .environmentObject(userID)
            Button(action: {
                let alertController = UIAlertController(title: "Reset Password", message: "To reset your password, enter the email associated with your account, then click OK.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                }))
                
                alertController.addTextField { (textField) in
                }
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] (_) in
                    let textField = alertController!.textFields![0]
                    if isValidEmail(textField.text ?? ""){
                        Auth.auth().sendPasswordReset(withEmail: textField.text!) { error in
                            if let err = error {
                                print("error sending reset email: ", err)
                            } else {
                                self.showingAlert = true
                                self.alertType = 2
                            }
                        }
                    } else {
                        self.showingAlert = true
                        self.alertType = 3
                    }
                }))
                UIApplication.shared.windows.first?.rootViewController!.present(alertController, animated: true, completion: nil)
            }) {
                Text("Forgot Password?")
            }
            GoogleScreen()
                .environmentObject(userID)
            LoginView()
                .environmentObject(userID)
            Spacer()
        }
        .alert(isPresented: Binding<Bool>(
            get: {
                return self.userID.updated || self.showingAlert
        },
            set: { newVal in
                self.userID.updated = false
                self.showingAlert = false
        }
        )) {
            switch alertType {
            case 0:
                return Alert(title: Text("Signed in!"), dismissButton: .default(Text("Okay")) {
                    self.presentationMode.wrappedValue.dismiss()
                    })
            case 1:
                return Alert(title: Text("Account Created!"), dismissButton: .default(Text("Okay")) {
                    self.presentationMode.wrappedValue.dismiss()
                    })
            case 2:
                return Alert(title: Text("Email Sent"), message: Text("An email with a link to reset your password has been sent to your email."), dismissButton: .default(Text("OK")))
            case 3:
                return Alert(title: Text("Invalid Email"), message: Text("Please try again"), dismissButton: .default(Text("OK")))
            default:
                return Alert(title: Text("Signed in!"), dismissButton: .default(Text("Okay")) {
                    self.presentationMode.wrappedValue.dismiss()
                    })
            }
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
            .environmentObject(UserID())
    }
}

//
//  EmailSignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/25/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct EmailSignIn: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loading = false
    @State private var error: Error?
    @State var showingError = false
    @Binding var loggedIn: Bool
    @Binding var session: SessionStore
    
    @EnvironmentObject var userID: UserID
    
    func signIn () {
        loading = true
        error = nil
        session.signIn(email: email, password: password) { (result, error) in
            if error != nil {
                self.session.signUp(email: self.email, password: self.password) { (result, error) in
                    if error != nil {
                        self.error = error
                        self.showingError = true
                        self.showAlert()
                        return
                    } else {
                        self.email = ""
                        self.password = ""
                        self.loggedIn = true
                    }
                    self.loading = false
//                    print("goot user:", result!.user, result!.user.uid)
                    UserDefaults.standard.set(result!.user.uid, forKey: "userID")
                    self.userID.id = result!.user.uid
                }
            } else {
                self.email = ""
                self.password = ""
                self.loading = false
                self.loggedIn = true
                UserDefaults.standard.set(result!.user.uid, forKey: "userID")
                self.userID.id = result!.user.uid
            }
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Login failed.", message: "Please check your email and password and try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.loading = false
            self.password = ""
        }))
        UIApplication.shared.windows.first?.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    var body: some View {
        VStack {
            TextField("Email Address", text: $email)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 2)
            )
            SecureField("Password", text: $password)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 2)
            )
            Button(action: signIn) {
                Text("Sign in with email")
            }
            if self.loading {
                ActivityIndicator(style: .large)
            }
        }
        .padding()
        //        .alert(isPresented: $showingError) {
        //            Alert(title: Text("Login failed."), message: Text("Please check your email and password and try again."), dismissButton: .default(Text("Ok"), action: {
        //                self.loading = false
        //                self.password = ""
        //                print("here")
        //            }))
        //        }
    }
}
struct EmailSignIn_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignIn(loggedIn: .constant(false), session: .constant(SessionStore()))
    }
}

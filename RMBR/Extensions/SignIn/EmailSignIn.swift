//
//  EmailSignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/25/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct EmailSignIn: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loading = false
    @State private var error: Error?
    @Binding var loggedIn: Bool
    @Binding var session: SessionStore
    @Binding var alertType: Int
    
    @EnvironmentObject var userID: UserID
    
    func signIn () {
        loading = true
        error = nil
        session.signIn(email: email, password: password) { (result, error) in
            if error != nil {
                self.error = error
                if error!._code == 17011 {
                    self.showConfirmAlert()
                } else {
                    self.showErrorAlert()
                }
                
            } else {
                self.email = ""
                self.password = ""
                self.loading = false
                self.loggedIn = true
                self.alertType = 0
                UserDefaults.standard.set(result!.user.uid, forKey: "userID")
                self.userID.id = result!.user.uid
            }
        }
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(title: "Login failed.", message: "Please check your email and password and try again. \(self.error!.localizedDescription)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.loading = false
            self.password = ""
        }))
        UIApplication.shared.windows.first?.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    func passwordNotMatchAlert() {
        let alertController = UIAlertController(title: "Passwords do not match", message: "Please check your password and try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.loading = false
            self.password = ""
        }))
        UIApplication.shared.windows.first?.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlert() {
        
        let alertController = UIAlertController(title: "New Account", message: "The email you entered does not yet have an account associated to it. If you are trying to create an account, please enter your passwordand click OK to confirm . Otherwise, click cancel.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            self.loading = false
            self.email = ""
            self.password = ""
        }))
        
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] (_) in
            let textField = alertController!.textFields![0]
            if (textField.text ?? "") == self.password {
                self.session.signUp(email: self.email, password: self.password) { (result, error) in
                    if error != nil {
                        self.error = error
                        self.showErrorAlert()
                        return
                    } else {
                        self.email = ""
                        self.password = ""
                        self.loggedIn = true
                    }
                    self.loading = false
                    self.alertType = 1
                    UserDefaults.standard.set(result!.user.uid, forKey: "userID")
                    self.userID.id = result!.user.uid
                }
            } else {
                self.passwordNotMatchAlert()
            }
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
    }
}
struct EmailSignIn_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignIn(loggedIn: .constant(false), session: .constant(SessionStore()), alertType: .constant(0))
    }
}

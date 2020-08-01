//
//  LoginView.swift
//  SwiftUISignInWithApple
//
//  Created by Alex Nagy on 04/11/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var signInWithAppleManager: SignInWithAppleManager
    @Environment(\.window) var window: UIWindow?
    
    @State private var signInWithAppleDelegates: SignInWithAppleDelegates! = nil
    
    @State private var isAlertPresented = false
    @State private var errDescription = ""
    
    @EnvironmentObject var userID: UserID
    
    var body: some View {
        VStack {
            SignInWithAppleButton()
                .frame(width: 250, height: 60)
                .onTapGesture {
                    self.showAppleLogin()
                }.alert(isPresented: $isAlertPresented) {
                    Alert(title: Text("Error"), message: Text(errDescription), dismissButton: .default(Text("Ok"), action: {
                        self.signInWithAppleManager.isUserAuthenticated = .signedOut
                    }))
                }
        }
    }
        
    private func showAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        performSignIn(using: [request])
    }
    
    private func performSignIn(using requests: [ASAuthorizationRequest]) {
        signInWithAppleDelegates = SignInWithAppleDelegates(window: self.window, onSignedIn: { (result) in
            switch result {
            case .success(let uid):
                UserDefaults.standard.set(uid, forKey: "userID")
                self.userID.id = uid
                self.signInWithAppleManager.isUserAuthenticated = .signedIn
            case .failure(let err):
                self.errDescription = err.localizedDescription
                self.isAlertPresented = true && (self.errDescription != "The operation couldn’t be completed. (com.apple.AuthenticationServices.AuthorizationError error 1001.)")
            }
        })
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = signInWithAppleDelegates
        controller.presentationContextProvider = signInWithAppleDelegates
        
        controller.performRequests()
    }
}
    
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        .environmentObject(UserID())
    }
}

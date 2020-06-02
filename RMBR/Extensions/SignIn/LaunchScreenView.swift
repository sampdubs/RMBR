////
////  LaunchScreenView.swift
////  SwiftUISignInWithApple
////
////  Created by Alex Nagy on 04/11/2019.
////  Copyright © 2019 Alex Nagy. All rights reserved.
////
//
//import SwiftUI
//import AuthenticationServices
//
//struct LaunchScreenView: View {
//    @EnvironmentObject var signInWithAppleManager: SignInWithAppleManager
//    @Environment(\.window) var window: UIWindow
//    
//    @State private var signInWithAppleDelegates: SignInWithAppleDelegates! = nil
//    
//    var body: some View {
//        ActivityIndicator(style: .large)
//            .onAppear {
//                self.signInWithAppleManager.checkUserAuth { (authState) in
//                    switch authState {
//                    case .undefined:
//                        print("auth state undefined")
//                        self.performExistingAccountSetupFlows()
//                    case .signedOut:
//                        print("auth state signedOut")
//                    case .signedIn:
//                        print("auth state signedIn")
//                    }
//                }
//        }
//    }
//    
//    private func performExistingAccountSetupFlows() {
//        let requests = [
//            ASAuthorizationAppleIDProvider().createRequest(),
//            ASAuthorizationPasswordProvider().createRequest()
//        ]
//        performSignIn(using: requests)
//    }
//    
//    private func performSignIn(using requests: [ASAuthorizationRequest]) {
//        signInWithAppleDelegates = SignInWithAppleDelegates(window: self.window, onSignedIn: { (result) in
//            switch result {
//            case .success(let userID):
//                UserDefaults.standard.set(userID, forKey: self.signInWithAppleManager.userIdentifierKey)
//                self.signInWithAppleManager.isUserAuthenticated = .signedIn
//            case .failure(_):
//                self.signInWithAppleManager.isUserAuthenticated = .signedOut
//            }
//        })
//        
//        let controller = ASAuthorizationController(authorizationRequests: requests)
//        controller.delegate = signInWithAppleDelegates
//        controller.presentationContextProvider = signInWithAppleDelegates
//        
//        controller.performRequests()
//    }
//}
//
//struct LaunchScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchScreenView()
//    }
//}

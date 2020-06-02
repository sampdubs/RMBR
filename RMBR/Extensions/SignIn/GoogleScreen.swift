//
//  GoogleSignIn.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/26/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct GoogleScreen: View {
    @EnvironmentObject var userID: UserID
    
    var body: some View {
        VStack {
            Google()
                .frame(width: 256, height: 60)
        }
    }
}

struct GoogleScreen_Previews: PreviewProvider {
    static var previews: some View {
        GoogleScreen()
    }
}

struct Google : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Google>) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.colorScheme = .dark
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: UIViewRepresentableContext<Google>) {
        
    }
}

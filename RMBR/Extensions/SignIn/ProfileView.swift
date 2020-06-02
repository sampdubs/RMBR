//
//  ProfileView.swift
//  SwiftUISignInWithApple
//
//  Created by Alex Nagy on 04/11/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var signInWithAppleManager: SignInWithAppleManager
    var body: some View {
        NavigationView {
            VStack() {
                Text("User identifier: \(UserDefaults.standard.string(forKey: "userID")!)")
                Spacer()
            }.padding()
                .navigationBarTitle("Welcome")
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

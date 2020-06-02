//
//  Login.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/25/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct Login: View {
    @State private var session: SessionStore = SessionStore()
    @State private var loggedIn = false
    
    @EnvironmentObject var userID: UserID
    
    var body: some View {
        VStack {
            EmailSignIn(loggedIn: $loggedIn, session: $session)
                .onAppear(perform: session.listen)
                .environmentObject(userID)
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

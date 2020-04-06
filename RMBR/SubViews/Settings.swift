//
//  Settings.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/2/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct Settings: View {
    @Binding var showSetting: Bool
    
    var body: some View {
        NavigationView {
            Text("Hello World")
            .navigationBarItems(leading:
                Button(action: {
                    self.showSetting = false
                }){
                    Image(systemName: "chevron.left")
            }, trailing: EmptyView())
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(showSetting: .constant(true))
    }
}

//
//  ContentView.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State private var showSetting = true
    @State private var selection = 0
    @EnvironmentObject var userID: UserID
    
    var body: some View {
        VStack {
            if showSetting {
                Settings(showSetting: self.$showSetting)
                    .environmentObject(userID)
            } else {
                //            Overarching container for all 3 main veiws with images at the bottom
                TabView (selection: self.$selection) {
                    Memories(showSetting: self.$showSetting)
                        .environmentObject(userID)
                        .tabItem {
                            Image(systemName: "person.2.square.stack.fill")
                            Text("Memories")
                    }.tag(0)
                    Tasks(showSetting: self.$showSetting)
                        .environmentObject(userID)
                        .tabItem {
                            Image(systemName: "alarm.fill")
                            Text("Tasks")
                    }.tag(1)
                    ToDoMain(showSetting: self.$showSetting)
                        .environmentObject(userID)
                        .tabItem {
                            Image(systemName: "checkmark.seal.fill")
                            Text("To Do")
                    }.tag(2)
                }
            }
            //            Bottom banner from Google AdMob
            AdBanner()
                .frame(height: 50)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

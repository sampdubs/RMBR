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
    @State private var showSetting = false
    
    var body: some View {
        VStack {
            if showSetting {
                Settings(showSetting: self.$showSetting)
            } else {
                //            Overarching container for all 3 main veiws with images at the bottom
                TabView {
                    Memories(showSetting: self.$showSetting)
                        .tabItem {
                            Image(systemName: "person.2.square.stack.fill")
                            Text("Memories")
                    }
                    Tasks(showSetting: self.$showSetting)
                        .tabItem {
                            Image(systemName: "alarm.fill")
                            Text("Tasks")
                    }
                    ToDoMain(showSetting: self.$showSetting)
                        .tabItem {
                            Image(systemName: "checkmark.seal.fill")
                            Text("To Do")
                    }
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

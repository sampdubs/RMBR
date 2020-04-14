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
    @State private var compression: Float = UserDefaults.standard.float(forKey: "compressionQuality")
    @State private var jpg: Bool = UserDefaults.standard.bool(forKey: "jpg")
    
    fileprivate func saveToggle() -> String {
        UserDefaults.standard.set(self.jpg, forKey: "jpg")
        return ""
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: VStack (alignment: .leading) {
                    Text("Compression quality: \(Float(self.compression), specifier: "%.2f")")
                        .bold()
                        .font(.system(size: 16))
                    Text("      This is how compressed the images you save in memories will be. A value of 1 means the images are saved at their original resolution. A value of 0.1 means the images are saved at 1 tenth the original resolution. This means the images won't look as good, but they will take up less space on your device")
                }) {
                    HStack {
                        Text("0.1")
                        Slider(value: self.$compression, in: 0.1...1, step: 0.01) { started in
                            if !started {
                                UserDefaults.standard.set(self.compression, forKey: "compressionQuality")
                            }
                        }
                        Text("1.0")
                    }
                }
                Section (header: VStack (alignment: .leading) {
                        Text("Saving as: \(self.jpg ? "JPEG" : "PNG")")
                            .bold()
                            .font(.system(size: 16))
                        Text("      JPEG images are able to acheive quality nearly as good as PNGs, but they take up much less space in storage. PNG images are lossless (meaning they don't compress the image at all unless you tell them to by changing the slider above), but take up more space. PNGs also support transparency.")
                    }) {
                    Toggle(isOn: self.$jpg) {
                        Text("Save images as JPEG")
                        Text(saveToggle())
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(leading:
                Button(action: {
                    self.showSetting = false
                }){
                    Image(systemName: "chevron.left")
                }
                .frame(width: 40, height: 40, alignment: .center)
                .contentShape(Rectangle()), trailing: EmptyView())
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(showSetting: .constant(true))
    }
}

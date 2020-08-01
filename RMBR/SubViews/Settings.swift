//
//  Settings.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 4/2/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFunctions

struct Settings: View {
    @Binding var showSetting: Bool
    @State private var compression: Float = UserDefaults.standard.float(forKey: "compressionQuality")
    @State private var jpg: Bool = UserDefaults.standard.bool(forKey: "jpg")
    @State private var showAlert: Bool = false
    @State private var alertType: Int = 0
    
    @EnvironmentObject var userID: UserID
    
    let functions = Functions.functions(region: "us-east1")
    
    fileprivate func saveToggle() -> String {
        UserDefaults.standard.set(self.jpg, forKey: "jpg")
        return ""
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section (header:
                        VStack (alignment: .leading) {
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
                        Text("      JPEG images are able to acheive quality nearly as good as PNGs, but they take up less space in storage. PNG images are lossless (meaning they don't compress the image at all unless you tell them to by changing the slider above), but take up more space. PNGs also support transparency.")
                    }) {
                        Toggle(isOn: self.$jpg) {
                            Text("Save images as JPEG")
                            Text(saveToggle())
                        }
                    }
                    Section (header: VStack (alignment: .leading) {
                        Text(userID.id == UIDevice.current.identifierForVendor!.uuidString ? "Sign in" : "Signed in")
                            .bold()
                            .font(.system(size: 16))
                        Text(userID.id == UIDevice.current.identifierForVendor!.uuidString ?
                            "      You can either create a new account so that you can have a backup of your data, or log into an existing account so that you have the same data shared between all devices logged into your account." :
                            "      You are signed in. This means that if you sign in to another device with the same account, it will show the same data (you would, for example have the same to-do lists shared between devices).")
                    }) {
                        if (userID.id == UIDevice.current.identifierForVendor!.uuidString) {
                            NavigationLink(destination: SignIn().environmentObject(userID)) {
                                Text("Sign Up/Log In")
                            }
                        } else {
                            Button(action: {
                                self.userID.id = UIDevice.current.identifierForVendor!.uuidString
                                UserDefaults.standard.set(self.userID.id, forKey: "userID")
                                self.showAlert = true
                                self.alertType = 0
                            }) {
                                Text("Sign out")
                            }
                        }
                    }
                    if (userID.id != UIDevice.current.identifierForVendor!.uuidString) {
                        Button(action: {
                            self.showAlert = true
                            self.alertType = 1
                        }) {
                            Text("Delete account")
                                .foregroundColor(Color.red)
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
            }.alert(isPresented: self.$showAlert) {
                if (alertType == 0 ) {
                    return Alert(title: Text("You are signed out."), message: Text("If you sign in again, all of your data will still be there. Any changes that you make now will be stored only on this phone."))
                } else {
                    if (Auth.auth().currentUser!.uid == self.userID.id) {
                        return Alert(
                            title: Text("Verify Identitiy"),
                            message: Text("Please login again with the account you are trying to delete to verify your identity"),
                            primaryButton: .default(Text("Cancel")),
                            secondaryButton: .default(
                                Text("OK"),
                                action: {
                                    let viewController = UIHostingController(rootView: MiniSignIn().environmentObject(globalUID))
                                    SessionStore().signOut()
                                    UIApplication.shared.windows.first?.rootViewController!.present(viewController, animated: true, completion: nil)
                                    
                                }
                            )
                        )
                    } else {
                        return Alert(
                            title: Text("Are you sure"),
                            message: Text("If you click delete, all of your data will be permenantly deleted. Only click delete if you are sure. Perhaps look back at your data to make sure you want to delete it."),
                            primaryButton: .default(Text("Cancel")),
                            secondaryButton: .destructive(Text("Delete"), action: {
                                let previousID = self.userID.id
                                self.userID.id = UIDevice.current.identifierForVendor!.uuidString
                                UserDefaults.standard.set(self.userID.id, forKey: "userID")
                                self.functions.httpsCallable("deleteUser").call(["path": "users/\(self.userID.id)"]) { (result, err) in
                                    if let err = err {
                                        print("error deleting account data : \(err)")
                                    } else {
                                        print(Auth.auth().currentUser!.uid, previousID)
                                        if (Auth.auth().currentUser!.uid == previousID) {
//                                            showLoginAlert()
                                                                                    Auth.auth().currentUser?.delete() { err in
                                                                                        if let err = err {
                                                                                            print("Error deleting user: ", err)
                                                                                        } else {
                                                                                            print("Deleted user")
                                                                                        }
                                                                                    }
                                        }
                                    }
                                }
                            }
                            ))
                    }
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(showSetting: .constant(true))
    }
}

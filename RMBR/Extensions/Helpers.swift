//
//  Helpers.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/3/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import UIKit
import CoreData
import WWCalendarTimeSelector
import Firebase
import CryptoKit
import AuthenticationServices
import Firebase

extension UITextView {
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

struct SettingsButton: View {
    @Binding var showSetting: Bool
    
    var body: some View {
        Button(action: {
            self.showSetting = true
        }){
            Image(systemName: "line.horizontal.3")
        }
        .frame(width: 40, height: 40, alignment: .center)
        .contentShape(Rectangle())
    }
}

class UserID: ObservableObject {
    @Published var id = "" {
        willSet {
            updated = newValue != UIDevice.current.identifierForVendor!.uuidString
        }
    }
    var updated = false
}

class DatePickerContainer: ObservableObject {
    @Published var picker = DatePicker()
    var date: Date {
        get {
            return picker.selector.optionCurrentDate
        }
        set {
            picker.selector.optionCurrentDate = newValue
        }
    }
}

struct DatePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let selector = WWCalendarTimeSelector.instantiate()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DatePicker>) -> UIViewController {
        selector.optionTopPanelTitle = "Schedule Reminder"
        selector.optionCurrentDate = Date()
        return selector
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DatePicker>) {
        
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}

func attachmentsText(_ x: Int) -> String {
    return "\(x) attachment" + (x == 1 ? "" : "s")
}

func taskPassed(_ t: Task) -> Bool {
    if t.repeats > 0 {
        return false
    }
    for d in t.date {
        if Calendar.current.date(from: d)! > Date() {
            return false
        }
    }
    return true
}

func sortTasks(_ tasks: [Task]) -> [Task] {
    var ts: [Task] = []
    var pastts: [Task] = []
    for t in tasks {
        if t.repeats == 0 && taskPassed(t) {
            pastts.append(t)
        } else {
            ts.append(t)
        }
    }
    return ts + pastts
}

func beautifyDate(_ d: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy h:mm a"
    return dateFormatter.string(from: d)
}

func ordinal(_ n: Int) -> String {
    var end = ""
    var m: Int
    if n < 20 {
        m = n
    } else {
        m = n % 10
    }
    switch m {
    case 1:
        end = "st"
    case 2:
        end = "nd"
    case 3:
        end = "rd"
    default:
        end = "th"
    }
    return String(n) + end
}

func beautifyDateComponents(_ d: DateComponents, _ r: Int) -> String {
    var out = ""
    let months = ["January", "February", "March",  "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    if r > 0 {
        out += "Repeats every "
    }
    switch r {
    //   yearly
    case 4:
        out += ordinal(d.day!)
        out += " of "
        out += months[d.month! - 1]
    //    monthly
    case 3:
        out += ordinal(d.day!)
        out += " of the month"
    //    weekly
    case 2:
        out += weekdays[d.weekday! - 1]
    //    daily
    case 1:
        out += "day"
    default:
        out = beautifyDate(Calendar.current.date(from: d)!)
    }
    if r > 0 {
        out += " at "
        out += String(d.hour! < 12 ? (d.hour! + 11) % 12 + 1 : (d.hour! - 1) % 12 + 1)
        out += ":"
        if d.minute! < 10 {
            out += "0"
        }
        out += String(d.minute!)
        out += d.hour! < 12 ? " AM" : " PM"
    }
    return out
}

extension Int: Identifiable {
    public var id: Int { self }
}

extension DateComponents: Identifiable {
    public var id: Double { Calendar.current.date(from: self)?.timeIntervalSince1970 ?? 0 }
}

func dateToComponents(_ d: Date, _ repeats: Int) -> DateComponents {
    var dateComponent = DateComponents()
    let calendar = Calendar.current
    dateComponent.calendar = Calendar.current
    switch repeats {
    //                    yearly
    case 4:
        dateComponent.hour = calendar.component(.hour, from: d)
        dateComponent.minute = calendar.component(.minute, from: d)
        dateComponent.month = calendar.component(.month, from: d)
        dateComponent.day = calendar.component(.day, from: d)
    //                    monthly
    case 3:
        dateComponent.hour = calendar.component(.hour, from: d)
        dateComponent.minute = calendar.component(.minute, from: d)
        dateComponent.day = calendar.component(.day, from: d)
    //                    weekly
    case 2:
        dateComponent.hour = calendar.component(.hour, from: d)
        dateComponent.minute = calendar.component(.minute, from: d)
        dateComponent.weekday = calendar.component(.weekday, from: d)
    //                    daily
    case 1:
        dateComponent.hour = calendar.component(.hour, from: d)
        dateComponent.minute = calendar.component(.minute, from: d)
    //                    never
    default:
        dateComponent.hour = calendar.component(.hour, from: d)
        dateComponent.minute = calendar.component(.minute, from: d)
        dateComponent.month = calendar.component(.month, from: d)
        dateComponent.day = calendar.component(.day, from: d)
        dateComponent.year = calendar.component(.year, from: d)
    }
    return dateComponent
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

extension UIImage {
    func rotated() -> UIImage? {
        if (self.imageOrientation == UIImage.Orientation.up ) {
            return self
        }
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func getData() -> Data {
        let comp = CGFloat(UserDefaults.standard.float(forKey: "compressionQuality"))
        if UserDefaults.standard.bool(forKey: "jpg") {
            return self.rotated()!.jpegData(compressionQuality: comp)!
        }
        return self.rotated()!.resized(withPercentage: comp)!.pngData()!
    }
}

struct AdBanner : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<AdBanner>) -> GADBannerView {
        // real: ca-app-pub-9472819037436786/3598098269
        // test: ca-app-pub-3940256099942544/6300978111
        
        let banner = GADBannerView(adSize: kGADAdSizeBanner)
//        banner.adUnitID = "ca-app-pub-3940256099942544/6300978111"      // test
        banner.adUnitID = "ca-app-pub-9472819037436786/3598098269"    // real
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: UIViewRepresentableContext<AdBanner>) {
        
    }
}

func showLoginAlert() {
    let alertController = UIAlertController(title: "Verify Identitiy", message: "Please login again with the account you are trying to delete to verify your identity", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
        let viewController = UIHostingController(rootView: MiniSignIn().environmentObject(globalUID))
        SessionStore().signOut()
        UIApplication.shared.windows.first?.rootViewController!.present(viewController, animated: true, completion: nil)
    }))
    UIApplication.shared.windows.first?.rootViewController!.present(alertController, animated: true, completion: nil)
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

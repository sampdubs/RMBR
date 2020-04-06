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

class RepeatPicker: ObservableObject {
    @Published var picker = RepeatPickerView()
    var repeats: Int {
        get {
            return picker.picker.selected
        }
        set {
            picker.picker.pickerView.selectRow(newValue, inComponent: 0, animated: false)
        }
    }
}

struct RepeatPickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyPicker
    
    let picker = MyPicker()
    func makeUIViewController(context: UIViewControllerRepresentableContext<RepeatPickerView>) -> MyPicker {
        return picker
    }
    func updateUIViewController(_ uiViewController: RepeatPickerView.UIViewControllerType, context: UIViewControllerRepresentableContext<RepeatPickerView>) {
    }
}

class MyPicker: UIViewController {
    private let dataSource = ["Never", "Daily", "Weekly", "Monthly", "Yearly"]
    var pickerView = UIPickerView()
    var selected = 0
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(pickerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MyPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selected = row
        return dataSource[row]
    }
}

class MOCContainer: ObservableObject {
    var moc: NSManagedObjectContext
    init(_ passedMoc: NSManagedObjectContext) {
        moc = passedMoc
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

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

class DatesContainer: ObservableObject {
    @Published var dates: [Date] = []
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

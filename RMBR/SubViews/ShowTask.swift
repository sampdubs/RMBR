//
//  ShowTask.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/24/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct ShowTask: View {
    @Binding var dates: [Date]
    @Binding var task: Task?
    @Binding var title: String
    @Binding var text: String
    @Binding var datePicker: DatePickerContainer
    @Binding var repeats: Int
    @State private var edit = false
    let repeatOptions = ["Never", "Daily", "Weekly", "Monthly", "Yearly"]
    let db = Firestore.firestore()
    
    fileprivate func saveTaskSheet() {
        self.edit = false
        if (self.text.isEmpty && self.title.isEmpty) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.body = self.text
        content.sound = UNNotificationSound.default
        var dateComponents: [DateComponents] = []
        let repeats = self.repeats
        for d in self.dates {
            dateComponents.append(dateToComponents(d, self.repeats))
        }
        var triggers: [UNCalendarNotificationTrigger] = []
        for d in dateComponents {
            triggers.append(UNCalendarNotificationTrigger(dateMatching: d, repeats: repeats > 0))
        }
        var requests: [UNNotificationRequest] = []
        var uuids: [UUID] = []
        for t in triggers {
            let uuid = UUID()
            requests.append(UNNotificationRequest(identifier: uuid.uuidString,
                                                  content: content, trigger: t))
            uuids.append(uuid)
        }
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: self.task!.identifier.map { $0.uuidString })
        for r in requests {
            notificationCenter.add(r) { (error) in
                if error != nil {
                    print(error!, error!.localizedDescription)
                }
            }
        }
        
        var uuidStrings: [String] = []
        for uuid in uuids {
            uuidStrings.append(uuid.uuidString)
        }
        var timestamps: [Timestamp] = []
        for var dC in dateComponents {
            if repeats > 0 {
                dC.year = 2000
            }
            timestamps.append(Timestamp(date: Calendar.current.date(from: dC)!))
        }
        
        
        self.task!.title = self.title
        self.task!.text = self.text
        self.task!.date = dateComponents
        self.task!.identifier = uuids
        self.task!.repeats = repeats
        
        let toSave: [String: Any] = [
            "identifier": uuidStrings,
            "repeats": repeats,
            "date": timestamps,
            "title": self.title,
            "text": self.text
        ]

        db.document("users/user-id/tasks/\(self.task!.id)").setData(toSave)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if self.task!.text != "" {
                    Text(self.task!.text)
                    Spacer()
                }
                List (self.task!.date) { d in
                    Text(beautifyDateComponents(d!, Int(self.task!.repeats)))
                }
            }
            .navigationBarTitle(self.task!.title)
            .navigationBarItems(trailing: Button("Edit") {
                self.edit.toggle()
                self.repeats = self.task!.repeats
                self.datePicker.date = Date()
            })
        }
        .padding()
        .sheet(isPresented: self.$edit, onDismiss: self.saveTaskSheet) {
            AddTask(dates: self.$dates, title: self.$title, text: self.$text, datePicker: self.$datePicker, repeats: self.$repeats)
        }
    }
}

struct ShowTask_Previews: PreviewProvider {
    static var previews: some View {
        ShowTask(dates: .constant([]), task: .constant(nil), title: .constant("Preview"), text: .constant("test"), datePicker: .constant(DatePickerContainer()), repeats: .constant(0))
    }
}

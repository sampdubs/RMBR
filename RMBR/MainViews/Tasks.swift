//
//  Tasks.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/24/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI
import Firebase

struct Tasks: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.editMode) var editing
    
    @State private var tasks: [Task] = []
    @State private var showSheet = false
    @State private var showAlert = false
    @State private var sheetType = "add"
    @State private var showingTask: Task?
    @State private var dates: [Date] = []
    @State private var title: String = ""
    @State private var text: String  = ""
    @State private var datePicker: DatePickerContainer = DatePickerContainer()
    @State private var repeats: Int = 0
    @Binding var showSetting: Bool
    let repeatOptions = ["Never", "Daily", "Weekly", "Monthly", "Yearly"]
    let db = Firestore.firestore()
    
    fileprivate func taskElement(_ task: Task) -> some View {
        return Button (action: {
            self.title = task.title
            self.text = task.text
            self.repeats = task.repeats
            self.datePicker.date = Date()
            self.dates = task.date.map { Calendar.current.date(from: $0)! }
            self.showingTask = task
            self.sheetType = "show"
            self.showSheet = true
        }) {
            VStack(alignment: .leading) {
                Text(task.title)
                    .bold()
                    .font(.headline)
                    .foregroundColor(taskPassed(task) ? .gray : self.colorScheme == .light ? .black : .white)
                Text(task.text)
                    .foregroundColor(taskPassed(task) ? .gray : self.colorScheme == .light ? .black : .white)
            }
        }
    }
    
    fileprivate func saveTaskSheet() {
        if (self.text.isEmpty && self.title.isEmpty) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.body = self.text
        content.sound = UNNotificationSound.default
        
        var dateComponents: [DateComponents] = []
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
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
        
        for r in requests {
            notificationCenter.add(r) { (error) in
                if error != nil {
                    print(error!, error!.localizedDescription)
                }
            }
        }
        
        notificationCenter.getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .denied:
                self.showAlert = true
                break
            case .authorized:
                self.showAlert = false
                break
            default:
                self.showAlert = true
                break
            }
        })
        
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
                
        let toSave: [String: Any] = [
            "identifier": uuidStrings,
            "repeats": repeats,
            "date": timestamps,
            "title": self.title,
            "text": self.text
        ]

        db.collection("users/user-id/tasks").addDocument(data: toSave)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack() {
                    Text("Add New Task")
                        .font(.headline)
                    Button(action: {
                        self.sheetType = "add"
                        self.datePicker.date = Date()
                        self.showSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
                if self.tasks.count == 1 {
                    Text("1 task")
                } else {
                    Text(String(self.tasks.count) + " tasks")
                }
                List {
                    ForEach(sortTasks(tasks), id: \.id) { task in
                        self.taskElement(task)
                    }
                    .onDelete { IndexSet in
                        guard 0 < self.tasks.count else { return }
                        let toDelete = self.tasks[IndexSet.first!]
                        //                        After deleting the task object, also delete the system notification corresponding to it
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: toDelete.identifier.map { $0.uuidString })
                        self.db.document("users/user-id/tasks/\(toDelete.id)").delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            }
                        }
                    }
                    if self.tasks.count > 0 && taskPassed(self.tasks.last!) {
                        Button(action: {
                            let batch = self.db.batch()
                            for task in self.tasks {
                                if taskPassed(task) {
                                    let doc = self.db.document("users/user-id/tasks/\(task.id)")
                                    batch.deleteDocument(doc)
                                }
                            }
                            batch.commit() { err in
                                if let err = err {
                                    print("Error writing batch \(err)")
                                }
                            }
                        }){
                            Text("Delete expired tasks")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitle("Tasks")
            .navigationBarItems(leading:
                Button(action: {
                    self.showSetting = true
                }){
                    Image(systemName: "line.horizontal.3")
            }, trailing: EditButton())
            .sheet(isPresented: self.$showSheet, onDismiss: {
                if self.sheetType == "add" {
                    self.saveTaskSheet()
                }
                
                self.title = ""
                self.text = ""
                self.repeats = 0
                self.datePicker.date = Date()
                self.dates = []
            }
            ) {
                if self.sheetType == "add" {
                    AddTask(dates: self.$dates, title: self.$title, text: self.$text, datePicker: self.$datePicker, repeats: self.$repeats)
                    
                } else {
                    ShowTask(dates: self.$dates, task: self.$showingTask, title: self.$title, text: self.$text, datePicker: self.$datePicker, repeats: self.$repeats)
                }
            }
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text("Notifications"), message: Text("In order to recieve reminders from this app, please turn on notifications"), dismissButton: .default(Text("Okay")) {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // nothing needs to be done, this means the link opened successfully
                        })
                     }
                    })
            }
        }
        .onAppear {
            self.db.collection("users/user-id/tasks")
                .addSnapshotListener { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.tasks.removeAll()
                        for document in querySnapshot!.documents {
                            self.tasks.append(Task(document.documentID, document.data()))
                        }
                    }
            }
        }
    }
}

struct Tasks_Previews: PreviewProvider {
    static var previews: some View {
        Tasks(showSetting: .constant(false))
    }
}

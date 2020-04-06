//
//  AddTask.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/24/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct AddTask: View {
    
    @Binding var dates: [Date]
    @Binding var title: String
    @Binding var text: String
    @Binding var datePicker: DatePickerContainer
    @Binding var repeats: Int
    @State var showingDP = false
    @State var addBody = false
    let repeatOptions = ["Never", "Daily", "Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(Font.system(size: 30, design: .default))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Toggle(isOn: Binding<Bool>(
                        get: {return self.addBody || self.text != ""},
                        set: {p in
                            if !p {
                                self.text = ""
                                self.addBody = false;
                            } else {
                                self.addBody = true;
                            }
                            })) {
                        Text("Include body")
                    }
                    if addBody || self.text != "" {
                        TextField("Body", text: $text)
                            .font(Font.system(size: 20, design: .default))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                NavigationLink(destination: TaskTimes(dates: self.$dates, showingDP: self.$showingDP, repeats: self.$repeats, repeatOptions: self.repeatOptions)) {
                    Text("Alert times")
                }
                
            }
            .navigationBarTitle("Edit Task")
        }
        .sheet(isPresented: self.$showingDP, onDismiss: {
            self.dates.append(self.datePicker.date)
        }) {
            self.datePicker.picker
        }
    }
}

struct AddTask_Previews: PreviewProvider {
    static var previews: some View {
        AddTask(dates: .constant([]), title: .constant("test"), text: .constant("Preview"), datePicker: .constant(DatePickerContainer()), repeats: .constant(0))
    }
}

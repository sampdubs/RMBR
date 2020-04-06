//
//  TaskTimes.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 3/16/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct TaskTimes: View {
    
    @Binding var dates: [Date]
    @Binding var showingDP: Bool
    @Binding var repeats: Int
    var repeatOptions: [String]
    @State private var update: Bool = true
    
    fileprivate func showDates(_ i: Int) -> some View {
        return HStack {
            Text(beautifyDate(self.dates[i]))
            Button(action: {
                self.dates.remove(at: i)
                self.update.toggle()
            }) {
                Text("Remove Time")
            }
            .font(.footnote)
        }
        .frame(height: 50)
    }
    
    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        return VStack {
            Button(action: {
                self.showingDP = true
            }) {
                Text("Add Time")
            }
            List {
                ForEach(0..<self.dates.count, id: \.id) { i in
                    self.showDates(i)
                }
                .onDelete { IndexSet in
                    guard 0 < self.dates.count else { return }
                    self.dates.remove(at: IndexSet.first!)
                    self.update.toggle()
                }
            }
            Section{
            Text("Repeats:")
            Picker("Repeats", selection: $repeats) {
                ForEach(0 ..< repeatOptions.count) {
                    Text(self.repeatOptions[$0])

                }
            }
            .labelsHidden()}
            Text(self.update ? " " : "")
            .hidden()
        }
    }
}

struct TaskTimes_Previews: PreviewProvider {
    static var previews: some View {
        TaskTimes(dates: .constant([]), showingDP: .constant(false), repeats: .constant(0), repeatOptions: ["Never", "Daily", "Weekly", "Monthly", "Yearly"])
    }
}

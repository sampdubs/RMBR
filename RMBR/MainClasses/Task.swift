//
//  Task+CoreDataClass.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/24/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation
import Firebase

public class Task: Identifiable {
    public var identifier: [UUID]
    public var repeats: Int
    public var date: [DateComponents]
    public var title: String
    public var text: String
    public var id: String
    
    init(_ id: String, _ firestoreData: [String: Any]) {
        self.id = id
        self.identifier = []
        for str in (firestoreData["identifier"] as? [String] ?? []) {
            self.identifier.append(UUID(uuidString: str)!)
        }
        self.repeats = firestoreData["repeats"] as? Int ?? 0
        self.date = []
        for ts in (firestoreData["date"] as? [Timestamp] ?? []) {
            self.date.append(dateToComponents(ts.dateValue(), self.repeats))
        }
        self.title = firestoreData["title"] as? String ?? ""
        self.text = firestoreData["text"] as? String ?? ""
    }
}

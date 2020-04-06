//
//  ToDo+CoreDataClass.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/12/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation

public class ToDo: Identifiable {
    public var text: String
    public var done: Bool
    public var order: Int
    public var id: String
    
    init(_ id: String, _ firestoreData: [String: Any]) {
        self.id = id
        self.text = firestoreData["text"] as? String ?? ""
        self.done = firestoreData["done"] as? Bool ?? false
        self.order = firestoreData["order"] as? Int ?? 0
    }
}

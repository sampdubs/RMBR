//
//  Memory+CoreDataClass.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation
import UIKit
import Firebase

public class Memory: Identifiable {
    public var text: String
    public var title: String
    public var date: Date
    public var attachments: [UIImage]
    public var id: String
    
    init(_ id: String, _ firestoreData: [String: Any]) {
        self.id = id
        self.text = firestoreData["text"] as? String ?? ""
        self.title = firestoreData["title"] as? String ?? ""
        self.date = (firestoreData["date"] as? Timestamp ?? Timestamp(date: Date())).dateValue()
        let imageStrings = firestoreData["attachments"] as? [String] ?? []
        self.attachments = []
        for im in imageStrings {
            if let data = Data(base64Encoded: im, options: .ignoreUnknownCharacters) {
                self.attachments.append(UIImage(data: data) ?? UIImage())
            }
        }
    }
    
    func imageStrings() -> [String] {
        var output: [String] = []
        for im in self.attachments {
            if let str = im.toString() {
                output.append(str)
            }
        }
        return output
    }
}

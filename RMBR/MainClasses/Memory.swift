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
import FirebaseStorage

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
            if im.prefix(7) == "pending" {
                self.attachments.append(loading)
            } else {
                let fileURL = getDocumentsDirectory().appendingPathComponent("\(im).png")
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: fileURL.path) {
                    if let loadedIm = UIImage(contentsOfFile: fileURL.path) {
                        self.attachments.append(loadedIm)
                    } else {
                        print("error loading image")
                    }
                } else {
                    print("reverting to storage load")
                    let index = self.attachments.count
                    self.attachments.append(loading)
                    let storageRef = Storage.storage().reference(withPath: "images/\(im)")
                    storageRef.getData(maxSize: 1024 * 1024 * 1024) { (data, error) -> Void in
                        if let error = error {
                            print("error getting data ", error)
                        } else {
                            let pic = UIImage(data: data!)
                            do {
                                try data!.write(to: fileURL)
                            } catch {
                                print("error writing image to file")
                            }
                            self.attachments[index] = pic!
                        }
                    }
                }
            }
        }
    }
}

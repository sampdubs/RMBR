//
//  Memory+CoreDataProperties.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 8/30/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Memory {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var attachments: [UIImage]?
    @NSManaged public var id: String
}

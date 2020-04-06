//
//  Task+CoreDataProperties.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/24/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation
import CoreData

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        let request = NSFetchRequest<Task>(entityName: "Task")
        let sortDescriptor = NSSortDescriptor(key: "repeats", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    @NSManaged public var identifier: [UUID]?
    @NSManaged public var repeats: Int16
    @NSManaged public var date: [DateComponents]?
    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var id: String

}

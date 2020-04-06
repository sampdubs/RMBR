//
//  ToDo+CoreDataProperties.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/12/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//
//

import Foundation
import CoreData

extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        let request = NSFetchRequest<ToDo>(entityName: "ToDo")
        let sortDescriptor1 = NSSortDescriptor(key: "done", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        return request
    }

    @NSManaged public var text: String?
    @NSManaged public var done: Bool
    @NSManaged public var order: Int16
    @NSManaged public var id: String

}

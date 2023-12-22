//
//  Mine+CoreDataProperties.swift
//  
//
//  Created by 賀華 on 2023/12/9.
//
//

import Foundation
import CoreData


extension Mine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mine> {
        return NSFetchRequest<Mine>(entityName: "Mine")
    }

    @NSManaged public var myWearing: Data?
    @NSManaged public var name: String?
    @NSManaged public var wearing: NSArray?

}

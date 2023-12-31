//
//  DollHair+CoreDataProperties.swift
//  
//
//  Created by 賀華 on 2023/12/9.
//
//

import Foundation
import CoreData

extension DollHair {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DollHair> {
        return NSFetchRequest<DollHair>(entityName: "DollHair")
    }

    @NSManaged public var name: String?
    @NSManaged public var hair: NSArray?
    @NSManaged public var hairB: NSArray?
    @NSManaged public var color: NSArray?

}

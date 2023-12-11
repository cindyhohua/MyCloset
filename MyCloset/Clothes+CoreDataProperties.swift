//
//  Clothes+CoreDataProperties.swift
//  
//
//  Created by 賀華 on 2023/12/10.
//
//

import Foundation
import CoreData


extension Clothes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clothes> {
        return NSFetchRequest<Clothes>(entityName: "Clothes")
    }

    @NSManaged public var category: String?
    @NSManaged public var cloth: NSArray?
    @NSManaged public var clothB: NSArray?
    @NSManaged public var color: NSArray?
    @NSManaged public var content: String?
    @NSManaged public var image: Data?
    @NSManaged public var item: String?
    @NSManaged public var price: String?
    @NSManaged public var store: String?
    @NSManaged public var subcategory: String?
    @NSManaged public var draw: Data?

}

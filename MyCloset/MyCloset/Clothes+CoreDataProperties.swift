//
//  Clothes+CoreDataProperties.swift
//  
//
//  Created by 賀華 on 2023/11/18.
//
//

import Foundation
import CoreData


extension Clothes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clothes> {
        return NSFetchRequest<Clothes>(entityName: "Clothes")
    }

    @NSManaged public var category: String?
    @NSManaged public var subcategory: String?
    @NSManaged public var item: String?
    @NSManaged public var price: String?
    @NSManaged public var store: String?
    @NSManaged public var content: String?
    @NSManaged public var image: Data?

}

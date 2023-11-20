//
//  CoreDataManeger.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import Foundation
import CoreData

struct ClothesStruct {
    var category: String?
    var subcategory: String?
    var item: String?
    var price: String?
    var store: String?
    var content: String?
    var image: Data?
    var cloth: [String]?
    var clothB: [String]?
    var color: [CGFloat]?
}

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {
        print(NSPersistentContainer.defaultDirectoryURL())
    }


    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyCloset")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    

    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchClothesFor(category: String, subcategory: String) -> [ClothesStruct] {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@ AND subcategory == %@", category, subcategory)

        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            let clothesStructArray = result.map { clothesEntity in
                return ClothesStruct(
                    category: clothesEntity.category,
                    subcategory: clothesEntity.subcategory,
                    item: clothesEntity.item,
                    price: clothesEntity.price,
                    store: clothesEntity.store,
                    content: clothesEntity.content,
                    image: clothesEntity.image,
                    cloth: clothesEntity.cloth as? [String],
                    clothB: clothesEntity.clothB as? [String],
                    color: clothesEntity.color as? [CGFloat]
                )
            }
            return clothesStructArray
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return []
        }
    }

    
    func fetchAllCategoriesAndSubcategories() -> [String: [String]] {
        var categoriesWithSubcategories = [String: [String]]()

        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()

        do {
            let clothes = try managedObjectContext.fetch(fetchRequest)

            for cloth in clothes {
                if let category = cloth.category, let subcategory = cloth.subcategory {
                    if var subcategories = categoriesWithSubcategories[category] {
                        if !subcategories.contains(subcategory) {
                            subcategories.append(subcategory)
                        }
                        categoriesWithSubcategories[category] = subcategories
                    } else {
                        categoriesWithSubcategories[category] = [subcategory]
                    }
                }
            }
            return categoriesWithSubcategories
        } catch {
            print("Error fetching categories and subcategories: \(error.localizedDescription)")
            return [:]
        }
    }
    
    func addClothAndColor(category: String, subcategory: String, item: String, clothArray: [String], clothBArray: [String], color: [CGFloat]) {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@ AND subcategory == %@ AND item == %@", category, subcategory, item)
        
        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            if let existingClothes = result.first {
                existingClothes.cloth = clothArray as NSArray
                existingClothes.clothB = clothBArray as NSArray
                
                // Convert CGFloat array to NSArray
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                existingClothes.color = colorNSArray as NSArray
            } else {
                // Create a new Clothes object
                let newClothes = Clothes(context: managedObjectContext)
                newClothes.category = category
                newClothes.subcategory = subcategory
                newClothes.cloth = clothArray as NSArray
                newClothes.clothB = clothBArray as NSArray
                
                // Convert CGFloat array to NSArray
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                newClothes.color = colorNSArray as NSArray
            }
            
            saveContext()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    
    
    
    // MARK: - Fetch Data
    
    func fetchData() -> [ClothesStruct] {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        do {
            let clothes = try managedObjectContext.fetch(fetchRequest)
            let clothesStructArray = clothes.map { clothesEntity in
                return ClothesStruct(
                    category: clothesEntity.category,
                    subcategory: clothesEntity.subcategory,
                    item: clothesEntity.item,
                    price: clothesEntity.price,
                    store: clothesEntity.store,
                    content: clothesEntity.content,
                    image: clothesEntity.image,
                    cloth: clothesEntity.cloth as? [String],
                    clothB: clothesEntity.clothB as? [String],
                    color: clothesEntity.color as? [CGFloat]
                )
            }
            return clothesStructArray
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return []
        }
    }

    
    // MARK: - Add Data

    func addClothes(category: String, subcategory: String, item: String, price: String, store: String, content: String, image: Data?) {
        let newClothes = Clothes(context: managedObjectContext)
        newClothes.category = category
        newClothes.subcategory = subcategory
        newClothes.item = item
        newClothes.price = price
        newClothes.store = store
        newClothes.content = content
        newClothes.image = image

        saveContext()
    }

    // MARK: - Update Data

    func updateClothes(_ clothes: Clothes) {
        saveContext()
    }

    // MARK: - Delete Data

    func deleteClothes(_ clothes: Clothes) {
        managedObjectContext.delete(clothes)
        saveContext()
    }
    

}


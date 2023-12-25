//
//  CoreDataManeger.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import Foundation
import CoreData

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
                    color: clothesEntity.color as? [CGFloat],
                    draw: clothesEntity.draw
                )
            }
            return clothesStructArray
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchSpecificClothes(name: String) -> ClothesStruct? {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "item == %@", name)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            if let specificClothes = result.first {
                return ClothesStruct(
                    category: specificClothes.category,
                    subcategory: specificClothes.subcategory,
                    item: specificClothes.item,
                    price: specificClothes.price,
                    store: specificClothes.store,
                    content: specificClothes.content,
                    image: specificClothes.image,
                    cloth: specificClothes.cloth as? [String],
                    clothB: specificClothes.clothB as? [String],
                    color: specificClothes.color as? [CGFloat],
                    draw: specificClothes.draw
                )
            } else {
                print("Clothes with item name \(name) not found.")
                return nil
            }
        } catch {
            print("Error fetching specific clothes data: \(error.localizedDescription)")
            return nil
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
    
    func addClothAndColor(category: String, subcategory: String, item: String, clothArray: [String], clothBArray: [String], color: [CGFloat], draw: Data) {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@ AND subcategory == %@ AND item == %@", category, subcategory, item)
        
        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            if let existingClothes = result.first {
                existingClothes.cloth = clothArray as NSArray
                existingClothes.clothB = clothBArray as NSArray
                
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                existingClothes.color = colorNSArray as NSArray
                existingClothes.draw = draw
            } else {
                let newClothes = Clothes(context: managedObjectContext)
                newClothes.category = category
                newClothes.subcategory = subcategory
                newClothes.cloth = clothArray as NSArray
                newClothes.clothB = clothBArray as NSArray
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                newClothes.color = colorNSArray as NSArray
                newClothes.draw = draw
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
                    color: clothesEntity.color as? [CGFloat],
                    draw: clothesEntity.draw
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
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)
        
        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            if let existingClothes = result.first {
                existingClothes.item = item
                existingClothes.price = price
                existingClothes.store = store
                existingClothes.content = content
                existingClothes.image = image
            } else {
                let newClothes = Clothes(context: managedObjectContext)
                newClothes.category = category
                newClothes.subcategory = subcategory
                newClothes.item = item
                newClothes.price = price
                newClothes.store = store
                newClothes.content = content
                newClothes.image = image
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
        saveContext()
    }
    
    func deleteCloth(item: String) {
        let fetchRequest: NSFetchRequest<Clothes> = Clothes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            if let mineToDelete = result.first {
                managedObjectContext.delete(mineToDelete)
                saveContext()
            } else {
                print("Mine object with UUID \(item) not found for deletion.")
            }
        } catch {
            print("Error fetching Mine data for deletion: \(error.localizedDescription)")
        }
    }
    
    func deleteMine(uuid: String) {
        let fetchRequest: NSFetchRequest<Mine> = Mine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", uuid)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            if let mineToDelete = result.first {
                managedObjectContext.delete(mineToDelete)
                saveContext()
            } else {
                print("Mine object with UUID \(uuid) not found for deletion.")
            }
        } catch {
            print("Error fetching Mine data for deletion: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Mine
    func saveMineData(image: Data, selectedItem: [String], uuid: String) {
        let fetchRequest: NSFetchRequest<Mine> = Mine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", uuid)
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            
            if let existingMine = result.first {
                existingMine.myWearing = image
                existingMine.wearing = selectedItem as NSArray
            } else {
                let newMine = Mine(context: managedObjectContext)
                newMine.myWearing = image
                newMine.wearing = selectedItem as NSArray
                newMine.name = uuid
            }
            
            saveContext()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func fetchAllMineData() -> [Mine] {
        let fetchRequest: NSFetchRequest<Mine> = Mine.fetchRequest()

        do {
            let mineData = try managedObjectContext.fetch(fetchRequest)
            return mineData
        } catch {
            print("Error fetching Mine data: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchHair() -> HairStruct? {
        let fetchRequest: NSFetchRequest<DollHair> = DollHair.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "doll")
        
        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            if let dollHair = result.first {
                let hairArray = dollHair.hair as? [String] ?? []
                let hairBArray = dollHair.hairB as? [String] ?? []
                var colorArray: [CGFloat] = []
                if let colorNSArray = dollHair.color as? [NSNumber] {
                    colorArray = colorNSArray.map { CGFloat($0.floatValue) }
                }
                
                return HairStruct(hair: hairArray, hairB: hairBArray, color: colorArray)
            } else {
                print("Doll hair not found")
                return nil
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func addHair(hair: [String], hairB: [String],color: [CGFloat]) {
        let fetchRequest: NSFetchRequest<DollHair> = DollHair.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "doll")
        
        do {
            let result = try CoreDataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            if let existingHair = result.first {
                existingHair.hair = hair as NSArray
                existingHair.hairB = hairB as NSArray
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                existingHair.color = colorNSArray as NSArray
            } else {
                let newClothes = DollHair(context: managedObjectContext)
                newClothes.name = "doll"
                newClothes.hair = hair as NSArray
                newClothes.hairB = hairB as NSArray
                let colorNSArray = color.map { NSNumber(value: Float($0)) }
                newClothes.color = colorNSArray as NSArray
            }
            saveContext()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}


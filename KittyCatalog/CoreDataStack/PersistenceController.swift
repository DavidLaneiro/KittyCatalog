//
//  PersistenceController.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import CoreData

class PersistenceController{
    
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CatBreedsModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Save the context if there are any changes
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                
                // Print the error instead of Fatal
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

//
//  KittyCatalogApp.swift
//  KittyCatalog
//
//  Created by David Lourenço on 06/08/2024.
//

import SwiftUI

@main
struct KittyCatalogApp: App {
    
    let persistenceController = PersistenceController.shared

    // Set the given value to the views environment
    var body: some Scene {
        WindowGroup {
            CatBreedsView().environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

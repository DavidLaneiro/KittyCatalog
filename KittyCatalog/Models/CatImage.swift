//
//  CatImage.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation

// MARK: Model for the CatImage

struct CatImage : Codable {
    
    let id: String
    let width: Int
    let height: Int
    let url: String
    
    // Initializer for creating directly
    init(id: String, width: Int, height: Int, url: String) {
        self.id = id
        self.width = width
        self.height = height
        self.url = url
    }
    
    // Initializer for creating from Core Data entity
    init(from entity: CatImageEntity) {
        self.id = entity.id ?? ""
        self.width = Int(entity.width)
        self.height = Int(entity.height)
        self.url = entity.url ?? ""
    }

}

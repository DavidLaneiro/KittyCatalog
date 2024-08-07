//
//  CatBreed.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation

struct CatBreed: Codable, Identifiable {
    let id: String
    let name: String
    let temperament: String
    let origin: String
    let description: String
    let lifeSpan: String
    let wikipediaURL: String?
    let image: CatImage?
    
    enum CodingKeys: String, CodingKey {
        case id, name, temperament, origin, description
        case lifeSpan = "life_span"
        case wikipediaURL = "wikipedia_url"
        case image
    }
    
    // Initializer for creating directly
    init(id: String, name: String, temperament: String, origin: String, description: String, lifeSpan: String, wikipediaURL: String? = nil, image: CatImage? = nil) {
        self.id = id
        self.name = name
        self.temperament = temperament
        self.origin = origin
        self.description = description
        self.lifeSpan = lifeSpan
        self.wikipediaURL = wikipediaURL
        self.image = image
    }
    
    // Initializer for creating from Core Data entity
    init(from entity: CatBreedEntity) {
        self.id = entity.id ?? ""
        self.name = entity.name ?? ""
        self.origin = entity.origin ?? ""
        self.temperament = entity.temperament ?? ""
        self.description = entity.descriptionText ?? ""
        self.lifeSpan = entity.lifeSpan ?? ""
        self.wikipediaURL = entity.wikipediaURL
        if let imageEntity = entity.image {
            self.image = CatImage(from: imageEntity)
        } else {
            self.image = nil
        }
    }
}

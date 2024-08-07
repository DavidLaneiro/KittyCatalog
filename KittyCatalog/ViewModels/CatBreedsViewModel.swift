//
//  CatBreedsViewModel.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation
import Combine
import CoreData

// MARK: Logic of the App

class CatBreedsViewModel: ObservableObject {
    
    @Published var catBreeds: [CatBreed] = []
    @Published var favouriteBreeds: [CatBreed] = []
    @Published var searchText: String = ""
    @Published var isOffline: Bool = false
    @Published var isLoading: Bool = false
    @Published var canLoadMore: Bool = true

    private var cancellables = Set<AnyCancellable>()
    private let catAPIService = CatAPIService()
    private let persistenceController = PersistenceController.shared
    
    private var currentPage: Int = 0
    
    // Setup the limit of images per page
    private let itemsPerPage: Int = 10

    // When initialized gather the Cat Breeds
    init() {
        fetchCatBreeds()
    }

    
    // Main Load of Realtime Data
    func fetchCatBreeds() {
        
        // Start with a loading state
        isLoading = true
        
        // Look for cached data
        loadCachedBreeds(page: currentPage)

        // Real Request for updated data
        catAPIService.fetchCatBreeds(page: currentPage, limit: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    self?.isOffline = false
                case .failure(let error):
                    self?.isOffline = true
                    print("Error fetching cat breeds: \(error)")
                }
            }, receiveValue: { [weak self] breeds in
                guard let self = self else { return }
                
                // If the breeds received are less then the items per page we cant load more.
                if breeds.count < self.itemsPerPage {
                    self.canLoadMore = false
                }
                self.catBreeds.append(contentsOf: breeds)
                self.cacheBreeds(breeds)
            })
            .store(in: &cancellables)
    }

    
    // Load what is in Cache
    private func loadCachedBreeds(page: Int) {
        let context = persistenceController.viewContext
        let fetchRequest: NSFetchRequest<CatBreedEntity> = CatBreedEntity.fetchRequest()
        fetchRequest.fetchLimit = itemsPerPage
        fetchRequest.fetchOffset = page * itemsPerPage

        do {
            let entities = try context.fetch(fetchRequest)
            self.catBreeds.append(contentsOf: entities.map { CatBreed(from: $0) })
            if entities.count < itemsPerPage {
                self.canLoadMore = false
            }
        } catch {
            print("Failed to fetch cached cat breeds: \(error)")
        }
    }

    // When new real data received store it in cache
    private func cacheBreeds(_ breeds: [CatBreed]) {
        let context = persistenceController.viewContext

        for breed in breeds {
            let entity = CatBreedEntity(context: context)
            entity.id = breed.id
            entity.name = breed.name
            entity.origin = breed.origin
            entity.temperament = breed.temperament
            entity.descriptionText = breed.description
            entity.lifeSpan = breed.lifeSpan
            entity.wikipediaURL = breed.wikipediaURL
            
            if let image = breed.image {
                let imageEntity = CatImageEntity(context: context)
                imageEntity.id = image.id
                imageEntity.width = Int64(image.width)
                imageEntity.height = Int64(image.height)
                imageEntity.url = image.url
                entity.image = imageEntity
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to cache cat breeds: \(error)")
        }
    }

    // When a specific image appears, see if the list needs to load more Breeds
    func loadMoreBreedsIfNeeded(currentItem: CatBreed) {
        guard let lastItem = catBreeds.last else {
            return
        }

        if currentItem.id == lastItem.id && canLoadMore && !isLoading {
            currentPage += 1
            fetchCatBreeds()
        }
    }

    func addToFavourites(breed: CatBreed) {
        favouriteBreeds.append(breed)
    }

    func removeFromFavourites(breed: CatBreed) {
        favouriteBreeds.removeAll { $0.id == breed.id }
    }

    func filterBreeds() -> [CatBreed] {
        if searchText.isEmpty {
            return catBreeds
        } else {
            return catBreeds.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

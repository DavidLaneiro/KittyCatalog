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
    @Published var searchText: String = ""
    @Published var favoriteSearchText: String = "" // New variable for FavoritesView
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 0
    private let itemsPerPage = 10
    private let catAPIService: CatAPIService
    private let persistenceController: PersistenceController
    
    // Init ViewModel
    init(catAPIService: CatAPIService = CatAPIService(), persistenceController: PersistenceController = .shared) {
        self.catAPIService = catAPIService
        self.persistenceController = persistenceController
        
            // Fetch From API
            fetchCatBreeds()

    }
    
    func fetchCatBreeds() {
        // Initial State is Loading
        isLoading = true

        // Load breeds from cache first
        let cachedBreeds = loadBreedsFromCache()

        catAPIService.fetchCatBreeds(page: currentPage, limit: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    print("Error fetching cat breeds: \(error)")
                    self.catBreeds = cachedBreeds // Use cached breeds if API fails
                }
                // Stop the loading on API fail
                self.isLoading = false
            } receiveValue: { [weak self] breeds in
                guard let self = self else { return }

                // Merge with cached favorites
                let mergedBreeds = breeds.map { breed -> CatBreed in
                    var breed = breed
                    if let cachedBreed = cachedBreeds.first(where: { $0.id == breed.id }) {
                        breed.isFavorite = cachedBreed.isFavorite
                    }
                    return breed
                }

                // Save updated data to cache
                self.saveBreedsToCache(mergedBreeds)

                // Update the catBreeds
                if self.currentPage == 0 {
                    self.catBreeds = mergedBreeds
                } else {
                    self.catBreeds.append(contentsOf: mergedBreeds)
                }

                // Increment the page
                self.currentPage += 1

                // Stop the loading on success
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func saveBreedsToCache(_ breeds: [CatBreed]) {
        let context = persistenceController.container.viewContext
        context.perform {
            do {
                // Fetch existing breeds from cache
                let request: NSFetchRequest<CatBreedEntity> = CatBreedEntity.fetchRequest()
                let existingBreedEntities = try context.fetch(request)
                let existingBreedIDs = Set(existingBreedEntities.compactMap { $0.id })

                // Filter out breeds that are already in cache
                let newBreeds = breeds.filter { !existingBreedIDs.contains($0.id) }
                
                // Save new data to cache
                for (breedIndex, breed) in newBreeds.enumerated() {
                    let breedEntity = CatBreedEntity(context: context)
                    breedEntity.id = breed.id
                    breedEntity.name = breed.name
                    breedEntity.origin = breed.origin
                    breedEntity.temperament = breed.temperament
                    breedEntity.descriptionText = breed.description
                    breedEntity.lifeSpan = breed.lifeSpan
                    breedEntity.wikipediaURL = breed.wikipediaURL
                    breedEntity.isFavorite = false // Default to not favorite
                    
                    if let image = breed.image {
                        let imageEntity = CatImageEntity(context: context)
                        imageEntity.id = image.id
                        imageEntity.width = Int64(image.width)
                        imageEntity.height = Int64(image.height)
                        imageEntity.url = image.url
                        imageEntity.order = Int64(breedIndex) // Assign order based on the index
                        breedEntity.image = imageEntity
                    }
                }
                
                // Save uncommitted changes
                try context.save()
            } catch {
                print("Failed to save breeds to Core Data: \(error)")
            }
        }
    }
    
    // Get breeds from cache
    private func loadBreedsFromCache() -> [CatBreed] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<CatBreedEntity> = CatBreedEntity.fetchRequest()
        
        do {
            let breedEntities: [CatBreedEntity] = try context.fetch(request)
            return breedEntities.map { (breedEntity: CatBreedEntity) -> CatBreed in
                var breed = CatBreed(from: breedEntity)
                
                if let imageEntity = breedEntity.image {
                    breed.image = CatImage(from: imageEntity)
                }
                
                return breed
            }
        } catch {
            print("Failed to fetch breeds from Core Data: \(error)")
            return []
        }
    }
    

    // Change the favorite value for the breed passed as parameter
    func toggleFavorite(for breed: CatBreed) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<CatBreedEntity> = CatBreedEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", breed.id)
        
        do {
            let results = try context.fetch(request)
            if let breedEntity = results.first {
                breedEntity.isFavorite.toggle()
                try context.save()
            }
        } catch {
            print("Failed to update favorite status: \(error)")
        }
        
        if let index = catBreeds.firstIndex(where: { $0.id == breed.id }) {
            catBreeds[index].isFavorite.toggle()
        }
    }
    
    func loadMoreBreedsIfNeeded(currentItem: CatBreed?) {
        guard let currentItem = currentItem else {
            fetchCatBreeds()
            return
        }
        
        // Get the index that is 5 positions before the end of the catBreeds array.
        // If close of that index load more breeds.
        
        let thresholdIndex = catBreeds.index(catBreeds.endIndex, offsetBy: -5)
        if catBreeds.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            fetchCatBreeds()
        }
    }
    
    // Filter by the state of the text in the searchText Published var
    func filterBreeds() -> [CatBreed] {
        if searchText.isEmpty {
            return catBreeds
        } else {
            return catBreeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Filter for favorites based on favoriteSearchText
    func filterFavoriteBreeds() -> [CatBreed] {
        if favoriteSearchText.isEmpty {
            return catBreeds.filter { $0.isFavorite }
        } else {
            return catBreeds.filter { $0.isFavorite && $0.name.localizedCaseInsensitiveContains(favoriteSearchText) }
        }
    }
}

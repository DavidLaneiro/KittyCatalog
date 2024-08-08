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
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let itemsPerPage = 10
    private let catAPIService: CatAPIService
    private let persistenceController: PersistenceController
    
    // Init ViewModel
    init(catAPIService: CatAPIService = CatAPIService(), persistenceController: PersistenceController = .shared) {
        self.catAPIService = catAPIService
        self.persistenceController = persistenceController
        
        // Start by fetching the breeds
        fetchCatBreeds()
    }
    
    func fetchCatBreeds() {
        
        // Initial State is Loading
        isLoading = true
        catAPIService.fetchCatBreeds(page: currentPage, limit: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    print("Error fetching cat breeds: \(error)")
                    self.loadBreedsFromCache() // Load from cache if API fails
                }
                // Stop the loading on API fail
                self.isLoading = false
            } receiveValue: { [weak self] breeds in
                guard let self = self else { return }
                
                // Save updated data to cache
                self.saveBreedsToCache(breeds)
                
                // If first page set the value
                if self.currentPage == 1 {
                    self.catBreeds = breeds
                } else {
                    self.catBreeds.append(contentsOf: breeds) // Else append the value
                }
                
                // Increment the page
                self.currentPage += 1
            }
            .store(in: &cancellables)
    }
    
    private func saveBreedsToCache(_ breeds: [CatBreed]) {
        // Get the context
        let context = persistenceController.container.viewContext
        context.perform {
            do {
                for breed in breeds {
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
                        breedEntity.image = imageEntity
                    }
                }
                
                // Save uncommited changes
                try context.save()
            } catch {
                print("Failed to save breeds to Core Data: \(error)")
            }
        }
    }
    
    // Get breeds from cache
    private func loadBreedsFromCache() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<CatBreedEntity> = CatBreedEntity.fetchRequest()
        
        do {
            let breedEntities = try context.fetch(request)
            self.catBreeds = breedEntities.map { CatBreed(from: $0) }
        } catch {
            print("Failed to fetch breeds from Core Data: \(error)")
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
}

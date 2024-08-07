//
//  CatAPIService.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation
import Combine

class CatAPIService {

    // Base URL
    private let baseURL = "https://api.thecatapi.com/v1/breeds"
    
    // API KEY
    private var apiKey: String?
    
    // Initialize the service and load API key
    init() {
        // Load the API key from the configuration file
        self.apiKey = ConfigManager.loadAPIKey()
    }

    // Fetch the Cat Breeds with a result or an error
    func fetchCatBreeds() -> AnyPublisher<[CatBreed], APIError> {
        
        guard let url = URL(string: baseURL) else {
            return Fail(error: APIError.unknownError).eraseToAnyPublisher()
        }
        
        // Check if API key is available
        guard let apiKey = self.apiKey else {
            return Fail(error: APIError.missingAPIKey).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [CatBreed].self, decoder: JSONDecoder())
            .mapError { error in
                if let _ = error as? URLError {
                    return APIError.networkError
                } else {
                    return APIError.decodingError
                }
            }
            .eraseToAnyPublisher()
    }
}

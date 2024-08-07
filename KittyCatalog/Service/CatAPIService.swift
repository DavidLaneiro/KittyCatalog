//
//  CatAPIService.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation
import Combine

// MARK: API for KittyCatalog Data

class CatAPIService {
    
    // Base URL
    private let baseURL = "https://api.thecatapi.com/v1/breeds"
    
    // Personal API Key
    private let apiKey = "live_Re6QFt6XRBYftmqANqBeNBWfYLdryHneSOdJCGv5szzNTmzg2yRl6pfD1hsyfm3p"

    // Fetch the Cat Breeds with a result or an error
    func fetchCatBreeds() -> AnyPublisher<[CatBreed], APIError> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: APIError.unknownError).eraseToAnyPublisher()
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

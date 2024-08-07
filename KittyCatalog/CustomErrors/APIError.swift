//
//  APIError.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation

// MARK: Custom Errors for API 

enum APIError: Error {
    case networkError
    case decodingError
    case unknownError
}

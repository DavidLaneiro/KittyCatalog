//
//  ConfigManager.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import Foundation

struct ConfigManager {
    static func loadAPIKey() -> String? {
        // Locate the Config.plist file
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any],
           let apiKey = config["APIKey"] as? String {
            return apiKey
        }
        return nil
    }
}

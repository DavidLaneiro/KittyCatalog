//
//  MainTabView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 08/08/2024.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CatBreedsView()
                .tabItem {
                    Label("Breeds", systemImage: "list.dash")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}

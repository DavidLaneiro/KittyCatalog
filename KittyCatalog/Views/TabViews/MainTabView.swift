//
//  MainTabView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 08/08/2024.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = CatBreedsViewModel()
    var body: some View {
        TabView {
            CatBreedsView()
                .tabItem {
                    Label("Breeds", systemImage: "list.dash")
                }
                .environmentObject(viewModel)
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    MainTabView()
}

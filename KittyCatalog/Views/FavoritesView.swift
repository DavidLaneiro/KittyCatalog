//
//  FavoritesView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 08/08/2024.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @EnvironmentObject private var viewModel : CatBreedsViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    if viewModel.catBreeds.filter({ $0.isFavorite }).isEmpty {
                                           VStack {
                                               Text("No favorites to show 😞")
                                                   .font(.title2)
                                                   .foregroundColor(.secondary)
                                                   .padding()
                                           }
                                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else{
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filterFavoriteBreeds()) { breed in
                                    
                                NavigationLink(destination: CatBreedsDetailView(viewModel: self.viewModel, breed: breed)){
                                    VStack {
                                        if let imageUrl = breed.image?.url, let url = URL(string: imageUrl) {
                                            KFImage(url)
                                                    .placeholder {
                                                        ProgressView()
                                                            .frame(width: 100, height: 100)
                                                    }
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 100, height: 100)
                                        }
                                        Text(breed.name)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                        Button(action: {
                                            viewModel.toggleFavorite(for: breed)
                                        }) {
                                            Image(systemName: breed.isFavorite ? "heart.fill" : "heart")
                                                .foregroundColor(breed.isFavorite ? .red : .gray)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Favorites")
                .searchable(text: $viewModel.favoriteSearchText)
            }.foregroundStyle(.primary)
            
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}


#Preview {
    FavoritesView()
}

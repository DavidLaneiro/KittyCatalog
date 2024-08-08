//
//  CatBreedsView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//
import SwiftUI

struct CatBreedsView: View {
    @StateObject private var viewModel = CatBreedsViewModel()
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.filterBreeds()) { breed in
                                
                            NavigationLink(destination: CatBreedsDetailView(viewModel: self.viewModel, breed: breed)){
                                VStack {
                                    if let imageUrl = breed.image?.url, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        }
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
                                .onAppear {
                                    viewModel.loadMoreBreedsIfNeeded(currentItem: breed)
                            }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Cat Breeds")
                .searchable(text: $viewModel.searchText)
            }
            
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}


#Preview {
    CatBreedsView()
}

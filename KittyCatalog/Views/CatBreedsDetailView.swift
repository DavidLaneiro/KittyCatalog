//
//  CatBreedsDetailView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 07/08/2024.
//

import SwiftUI

struct CatBreedsDetailView: View {
    @ObservedObject var viewModel: CatBreedsViewModel
    var breed: CatBreed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                if let imageUrl = breed.image?.url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipShape(Rectangle())
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                
                Text("Origin: \(breed.origin)")
                    .font(.title2)
                
                Text("Temperament: \(breed.temperament)")
                    .font(.title3)
                
                Text("Description: \(breed.description)")
                    .font(.body)
                
                Text("Life Span: \(breed.lifeSpan) years")
                    .font(.body)
                
                if let wikipediaURL = breed.wikipediaURL, let url = URL(string: wikipediaURL) {
                    Link("Learn more on Wikipedia", destination: url)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
        .navigationTitle(breed.name)
        .navigationBarItems(trailing: Button(action: {
            viewModel.toggleFavorite(for: breed)
        }) {
            Image(systemName: breed.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(breed.isFavorite ? .red : .gray)
        })
        }
    }
}

#Preview {
    CatBreedsView()
}

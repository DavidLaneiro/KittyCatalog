//
//  LoadingView.swift
//  KittyCatalog
//
//  Created by David Lourenço on 08/08/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundColor(.white)
                .padding(20)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
        }
    }
}

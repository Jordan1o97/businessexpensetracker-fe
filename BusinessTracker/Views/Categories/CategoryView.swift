//
//  CategoryView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI

struct CategoryView: View {
    var category: Category
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
            }
            Spacer()
            AsyncImage(url: URL(string: category.icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
            } placeholder: {
                ProgressView()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = Category(name: "Sample Category", icon: "pencil", id: "12345")
        
        CategoryView(category: sampleCategory)
    }
}

//
//  CategoryMainView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI

struct CategoryMainView: View {
    @Binding var selectedCategory: (name: String, id: String)
    @Binding var isPresented: Bool
    
    @State private var showAddCategoryView = false
    @State private var categories: [Category] = []
    @State private var isAnimating: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                BannerContainerView()
                HStack {
                    Text("Category Tracker")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 50)

                    Spacer()

                    AdButton(onButtonAction: {
                        showAddCategoryView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20) // Add custom padding to create a gap between the button and the right edge
                    .fullScreenCover(isPresented: $showAddCategoryView) {
                        AddCategoryView(isPresented: $showAddCategoryView)
                            .onDisappear(perform: fetchCategories)
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        ForEach(categories, id: \.id) { category in
                            AdButton(onButtonAction: {
                                selectedCategory = (name: category.name, id: category.id)
                                isPresented = false
                            }) {
                                CategoryView(category: category)
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .padding(.bottom, 10)
                                    .foregroundColor(.black) // Keep the text color black
                            }
                        }
                    }
                }
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchCategories)
                BannerContainerView()
            }
            if isAnimating {
                ActivityIndicatorView(isAnimating: isAnimating)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }

    func fetchCategories() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        self.isAnimating = true

        CategoryService().fetchCategoriesByUserId(userId: userId, authToken: token) { result in
            switch result {
            case .success(let fetchedCategories):
                DispatchQueue.main.async {
                    self.categories = fetchedCategories
                    self.isAnimating = false
                    print("Categories: \(self.categories)")
                }
            case .failure(let error):
                print("Error fetching categories: \(error)")
                DispatchQueue.main.async {
                    self.isAnimating = false
                }
            }
        }
    }
}

struct CategoryMainView_Previews: PreviewProvider {
    @State static private var selectedCategory = (name: "", id: "")
    @State static private var isPresented = true
    
    static var previews: some View {
        CategoryMainView(selectedCategory: $selectedCategory, isPresented: $isPresented)
    }
}

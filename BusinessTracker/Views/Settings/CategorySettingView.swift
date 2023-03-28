//
//  CategorySettingView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-20.
//

import SwiftUI

struct CategorySettingView: View {
    @State var selectedCategory: Category?
    @Binding var isPresented: Bool
    
    @State private var showAddCategoryView = false
    @State private var showEditCategoryView = false
    @State private var categories: [Category] = []
    @State private var isAnimating: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                HStack {
                    BannerContainerView()
                    HStack {
                        Text("Category Tracker")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)

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
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        ForEach(categories, id: \.id) { category in
                            AdButton(onButtonAction: {
                                selectedCategory = category
                                showEditCategoryView = true
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
                .fullScreenCover(isPresented: Binding(get: { showEditCategoryView }, set: { showEditCategoryView = $0 })) {
                    EditCategoryView(isPresented: Binding(get: { showEditCategoryView }, set: { showEditCategoryView = $0 }), category: selectedCategory!)
                        .onDisappear(perform: fetchCategories)
                }
                .onAppear(perform: fetchCategories)
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
        DispatchQueue.global(qos: .background).async {
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
}

struct CategorySettingView_Previews: PreviewProvider {
    @State static private var isPresented = true
    
    static var previews: some View {
        CategorySettingView(isPresented: $isPresented)
    }
}

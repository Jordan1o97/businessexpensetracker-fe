//
//  EditCategoryView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI

struct EditCategoryView: View {
    @Binding var isPresented: Bool
    @State var category: Category

    @State private var name: String = ""
    @State private var icon: String = ""
    @State private var image: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var isLoading: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    var canSave: Bool {
        return !name.isEmpty
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            VStack {
                BannerContainerView()
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Text("Edit Category")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)

                    Spacer()

                    AdButton(onButtonAction: {
                        saveCategory()
                    }) {
                        Text("Save")
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                    .padding(.trailing, 20)
                }

                Form {
                    Section {
                        HStack {
                            Text("Name: ")
                            TextField("Building Supplies", text: $name)
                        }
                        HStack {
                            Text("Image: ")
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                            }
                            Spacer()
                            Button(action: {
                                showImagePicker.toggle()
                            }) {
                                Text("Choose Image")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $image, isPresented: $showImagePicker)
                }

                Spacer()
            }

            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ActivityIndicatorView(isAnimating: isLoading)
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color(.systemBackground).opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onAppear() {
            self.name = category.name
            self.icon = category.icon
            
        }
    }
    
    func saveCategory() {
        isLoading = true

        let newCategory = Category(name: name, icon: icon, id: category.id)

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        CategoryService().saveCategory(category: newCategory, authToken: token) { result in
            DispatchQueue.global(qos: .background).async {
                isLoading = false
                switch result {
                case .success(let category):
                    print("Category saved: \(category)")
                    isPresented = false
                case .failure(let error):
                    print("Error saving category: \(error)")
                    isPresented = false
                }
            }
        }
    }
    
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = Category(name: "Sample Category", icon: "pencil", id: "12345")
        EditCategoryView(isPresented: .constant(true), category: sampleCategory)
    }
}

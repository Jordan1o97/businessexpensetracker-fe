//
//  EditCategoryView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI
import Firebase
import FirebaseStorage

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

        guard let image = image else {
            print("No image selected")
            isLoading = false
            return
        }
        DispatchQueue.global(qos: .background).async {
            uploadImageToFirebaseStorage(image: image) { result in
                switch result {
                case .success(let imageURL):
                    
                    let newCategory = Category(name: name, icon: imageURL, id: UUID().uuidString)
                    
                    guard let token = getToken() else {
                        print("Token not found")
                        return
                    }
                    CategoryService().saveCategory(category: newCategory, authToken: token) { result in
                        DispatchQueue.main.async {
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
                    
                case .failure(let error):
                    print("Error uploading image: \(error)")
                    isPresented = false
                    isLoading = false
                }
            }
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG data"])))
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("category_images/\(imageName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("⚠️", "Api Error \(error)")
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("⚠️", "Image Error \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    print("💯", "Image Success")
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get download URL"])))
                    print("📛", "Error no URL")
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

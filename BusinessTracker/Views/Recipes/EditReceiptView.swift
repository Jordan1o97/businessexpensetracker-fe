//
//  EditReceiptView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI

import SwiftUI

struct EditReceiptView: View {
    @Binding var isPresented: Bool
    @State var receipt: Receipt
    
    @State private var date: Date = Date()
    @State private var category: (name: String, id: String) = ("", "")
    @State private var initialTotal: String = ""
    @State private var tax: String = ""
    @State private var tip: String = ""
    @State private var clientId: (name: String, id: String) = ("", "")
    @State private var paymentMode: String = ""
    @State private var description: String = ""
    @State private var status: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showCategoryMainView = false
    @State private var showClientMainView = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    
    var canSave: Bool {
        return !category.id.isEmpty && !initialTotal.isEmpty && !tax.isEmpty && !tip.isEmpty && !clientId.id.isEmpty && !paymentMode.isEmpty && !description.isEmpty
    }

    func saveReceipt() {
        isLoading = true
        print(receipt.id)
        let updatedReceipt = Receipt(id: receipt.id, category: category.id, date: date, initalTotal: Double(initialTotal) ?? 0.0, tax: Double(tax) ?? 0.0, tip: Double(tip) ?? 0.0, clientId: clientId.id, paymentMode: paymentMode, description: description, status: status) // Replace userId with the actual userId


        guard let token = getToken() else {
            print("Token not found")
            return
        }

        ReceiptService().updateReceipt(receipt: updatedReceipt, authToken: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let message):
                    print("Receipt saved: \(message)")
                    isPresented = false
                case .failure(let error):
                    print("Error saving receipt: \(error)")
                    isLoading = false
                    isPresented = false
                }
            }
        }
        isPresented = false
    }

    func fetchClientName(clientId: String) {
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        isLoading = true
        
        ClientService().fetchClientById(clientId: clientId, authToken: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let client):
                    self.clientId = (name: client.name, id: client.id)
                case .failure(let error):
                    print("Error fetching client name: \(error)")
                }
            }
        }
    }
    
    func fetchCategoryName(categoryId: String) {
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        isLoading = true
        
        CategoryService().fetchCategoryById(categoryId: categoryId, authToken: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let category):
                    self.category = (name: category.name, id: category.id)
                case .failure(let error):
                    print("Error fetching category name: \(error)")
                }
            }
        }
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
                    
                    Text("Edit Receipt")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    AdButton(onButtonAction: {
                        saveReceipt()
                    }) {
                        Text("Save")
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                    .padding(.trailing, 20)
                }
                
                Form {
                    Section {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        HStack {
                            Text("Initial Total:")
                            TextField("Initial Total", text: $initialTotal)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("Tax:")
                            TextField("Tax", text: $tax)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("Tip:")
                            TextField("Tip", text: $tip)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("Payment Mode:")
                            TextField("Payment Mode", text: $paymentMode)
                        }
                        HStack {
                            Text("Description:")
                            TextField("Description", text: $description)
                        }
                        HStack {
                            Text("Status:")
                            TextField("Status", text: $status)
                        }
                        AdButton(onButtonAction: {
                            showCategoryMainView.toggle()
                        }) {
                            HStack {
                                Text("Category:")
                                Text(category.name.isEmpty ? "Category" : "\(category.name)")
                                    .foregroundColor(category.name.isEmpty ? .gray : .primary)
                                Spacer()
                            }
                        }.sheet(isPresented: $showCategoryMainView) {
                            CategoryMainView(selectedCategory: $category, isPresented: $showCategoryMainView)
                        }

                        AdButton(onButtonAction: {
                            showClientMainView.toggle()
                        }) {
                            HStack {
                                Text("Client:")
                                Text(clientId.name.isEmpty ? "Client" : "\(clientId.name)")
                                    .foregroundColor(clientId.name.isEmpty ? .gray : .primary)
                                Spacer()
                            }
                        }
                        .sheet(isPresented: $showClientMainView) {
                            ClientMainView(selectedClient: $clientId, isPresented: $showClientMainView)
                        }
                    }
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
            self.date = receipt.date
            self.initialTotal = String(receipt.initalTotal)
            self.tax = String(receipt.tax)
            self.tip = String(receipt.tip)
            self.paymentMode = receipt.paymentMode
            self.description = receipt.description
            if let status = receipt.status {
                self.status = status
            }
            fetchClientName(clientId: receipt.clientId)
            fetchCategoryName(categoryId: receipt.category)
        }
    }
}

struct EditReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleReceipt = Receipt(id: "1a2b3c4d",
                                    category: "Food",
                                    date: Date(),
                                    initalTotal: 100.0,
                                    tax: 8.0,
                                    tip: 15.0,
                                    clientId: "c7852d88-aa90-4386-9671-839970522468",
                                    paymentMode: "Credit Card",
                                    description: "Dinner with client",
                                    status: "Submitted")
        EditReceiptView(isPresented: .constant(true), receipt: sampleReceipt)
    }
}

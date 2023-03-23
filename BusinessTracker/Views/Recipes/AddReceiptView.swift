//
//  AddReceiptView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI

struct AddReceiptView: View {
    @Binding var isPresented: Bool
    @Binding var scannedReceiptData: [String: Any]

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

    var editMode: Bool = false // Set this to true when editing an existing receipt

    var canSave: Bool {
        return !initialTotal.isEmpty && !paymentMode.isEmpty && !clientId.id.isEmpty && !category.id.isEmpty
    }

    func createReceipt() {
        isLoading = true

        let receiptId = UUID().uuidString // Replace with the existing receipt ID when in edit mode
        let newReceipt = Receipt(id: receiptId, category: category.id, date: date, initalTotal: Double(initialTotal) ?? 0.0, tax: Double(tax) ?? 0.0, tip: Double(tip) ?? 0.0, clientId: clientId.id, paymentMode: paymentMode, description: description, status: status) // Replace userId with the actual userId

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        ReceiptService().createReceipt(receipt: newReceipt, authToken: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let message):
                    print(message)
                    isPresented = false
                case .failure(let error):
                    print("Error saving receipt: \(error)")
                }
            }
        }
        isPresented = false
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
                    
                    Text(editMode ? "Edit Receipt" : "New Receipt")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    AdButton(onButtonAction: {
                        createReceipt()
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
        .onAppear {
            if let scannedTotal = scannedReceiptData["total"] as? Double {
                initialTotal = String(scannedTotal)
            }
            if let scannedTax = scannedReceiptData["tax"] as? Double {
                tax = String(scannedTax)
            }
            if let scannedTip = scannedReceiptData["tip"] as? Double {
                tip = String(scannedTip)
            }
        }
    }
}

struct AddReceiptView_Previews: PreviewProvider {
    @State static private var scannedReceiptData: [String: Any] = [:]

    static var previews: some View {
        AddReceiptView(isPresented: .constant(true), scannedReceiptData: $scannedReceiptData)
    }
}

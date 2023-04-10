//
//  ReceiptMainView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-19.
//

import SwiftUI
import Combine
import GoogleMobileAds

struct ReceiptMainView: View {
    @State private var scannedReceiptData: [String: Any] = [:]
    @State private var selectedFilter: Int = 0
    @State private var showAddReceiptView = false
    @State private var receipts: [Receipt] = []
    @State private var clientNames: [String: String] = [:]
    @State private var categoryNames: [String: String] = [:]
    @State private var isAnimating: Bool = false
    @State private var groupedReceipts: [(String, [Receipt])] = []
    @State private var isEditViewPresented = false
    @State private var selectedReceipt: Receipt?
    @State private var total: Double = 0.0
    @State private var pdfData: Data?
    @State private var isSharing = false
    @State private var showPDFPreview = false
    @State private var cancellable: AnyCancellable?
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false
    @Environment(\.colorScheme) var colorScheme
    
    private let filterTitles = ["Day", "Month", "Year", "Category", "Client"]
    private var activityItems: [Any] {
        if let data = pdfData {
            print("PDF data is available")
            return [data]
        } else {
            print("PDF data is nil")
            return [Data()]
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                BannerContainerView();
                HStack {
                    Text("Receipts")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 85)
                    
                    Spacer()
                    AdButton(onButtonAction: {
                        exportReceiptsPDF()
                        isAnimating = true;
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 18, height: 24)
                    }
                    .padding(.trailing, 10)
                    .sheet(isPresented: $showPDFPreview) {
                        PDFPreviewView(pdfData: pdfData ?? Data(), isPresented: $showPDFPreview)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    AdButton(onButtonAction: {
                        showAddReceiptView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20)
                    .sheet(isPresented: $showAddReceiptView) {
                        
                        AddReceiptView(isPresented: $showAddReceiptView, scannedReceiptData: $scannedReceiptData)
                            .onDisappear(perform: fetchReceipts)
                    }
                }
                .padding(.horizontal)
                
                FilterBarView(filterTitles: filterTitles, selectedFilter: $selectedFilter)
                    .frame(width: UIScreen.main.bounds.width, height: 50)
                    .padding(.top, 16)
                    .onChange(of: selectedFilter) { _ in
                        fetchReceipts()
                    }
                
                VStack {
                    HStack {
                        Text("Total:")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f", total))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                }
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .background(Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 0.8)))
                .cornerRadius(20)
                .padding(.top, 16)
                
                ScrollView {
                    VStack {
                        ForEach(groupedReceipts, id: \.0) { group in
                            Text(getGroupHeader(group: group))
                                .font(.system(size: 18, weight: .bold))
                                .padding(.top)
                            ForEach(group.1) { receipt in
                                if let clientName = clientNames[receipt.clientId],
                                   let categoryName = categoryNames[receipt.category] {
                                    
                                    AdButton(onButtonAction: {
                                        selectedReceipt = receipt
                                        isEditViewPresented = true
                                    }) {
                                        ReceiptView(receipt: receipt, clientName: clientName, categoryName: categoryName)
                                            .padding(.horizontal)
                                            .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                            .padding(.bottom, 10)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchReceipts)
                .fullScreenCover(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 })) {
                    EditReceiptView(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 }), receipt: selectedReceipt!)
                        .onDisappear(perform: fetchReceipts)
                }
                BannerContainerView();
                
                if isAnimating {
                    ActivityIndicatorView(isAnimating: isAnimating)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                if disableTouch {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {}
                        .allowsHitTesting(true)
                }
            }
            .onChange(of: isAnimating) { newValue in
                disableTouch = newValue
            }
            .onAppear(perform: fetchReceipts)
            .fullScreenCover(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 })) {
                EditReceiptView(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 }), receipt: selectedReceipt!)
                    .onDisappear(perform: fetchReceipts)
            }
        }
    }
    
    private func exportReceiptsPDF() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        DispatchQueue.main.async {
            isAnimating = true
        }
        DispatchQueue.global(qos: .background).async {
            cancellable = ReceiptService().fetchReceiptsPDF(userId: userId, authToken: token)
                .receive(on: DispatchQueue.main) // Make sure to receive the value on the main thread
                .sink { completion in
                    isAnimating = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching PDF data: \(error)")
                    }
                } receiveValue: { data in
                    print("Received PDF data")
                    self.pdfData = data
                    self.showPDFPreview = true
                    self.isAnimating = false
                }
        }
        
    }
    
    func getGroupHeader(group: (String, [Receipt])) -> String {
        if selectedFilter == 0 { // If the Day filter is selected
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let date = dateFormatter.date(from: group.0) {
                dateFormatter.dateFormat = "MMMM d, yyyy"
                return dateFormatter.string(from: date)
            }
        }
        return group.0
    }
    
    func fetchTotal() {
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
            ReceiptService().fetchTotalReceiptsByUserId(userId: userId, authToken: token) { result in
                switch result {
                case .success(let (total)):
                    DispatchQueue.main.async {
                        self.total = total
                    }
                case .failure(let error):
                    print("Error fetching receipt total: \(error)")
                    DispatchQueue.main.async {
                        self.isAnimating = false
                    }
                }
            }
        }
    }
    
    func fetchReceipts() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        DispatchQueue.main.async {
            self.isAnimating = true
        }

        DispatchQueue.global(qos: .background).async {
            ReceiptService().fetchFilteredReceiptClientsAndCategories(userId: userId, authToken: token, selectedFilter: selectedFilter) { result in
                switch result {
                case .success(let (groupedReceipts, clientNames, categoryNames)):
                    let sortedGroupedReceipts = groupedReceipts.map { (key, receipts) -> (String, [Receipt]) in
                        if selectedFilter == 1 || selectedFilter == 2 || selectedFilter == 3 {
                            let sortedReceipts = receipts.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                            return (key, sortedReceipts)
                        } else {
                            return (key, receipts)
                        }
                    }
                    let flattenedReceipts = sortedGroupedReceipts.flatMap { $0.1 } // Flatten the array of receipts
                    
                    DispatchQueue.main.async {
                        self.receipts = flattenedReceipts
                        self.clientNames = clientNames
                        self.categoryNames = categoryNames

                        // Create a DateFormatter to parse the date strings
                        let dateFormatter = DateFormatter()
                        
                        // Sort the groupedReceipts by their keys as dates
                        self.groupedReceipts = groupedReceipts.sorted(by: { (group1, group2) -> Bool in
                            if selectedFilter == 0 || selectedFilter == 1 {
                                dateFormatter.dateFormat = selectedFilter == 0 ? "MM/dd/yyyy" : "MM/yyyy"
                                if let date1 = dateFormatter.date(from: group1.0), let date2 = dateFormatter.date(from: group2.0) {
                                    return date1 < date2
                                }
                            } else {
                                // If dates can't be parsed, fall back to string comparison
                                return group1.0 < group2.0
                            }
                            return false
                        }).map { (key, receipts) -> (String, [Receipt]) in
                            if selectedFilter == 2 || selectedFilter == 3 || selectedFilter == 4 {
                                let sortedReceipts = receipts.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                return (key, sortedReceipts)
                            } else {
                                return (key, receipts)
                            }
                        }

                        fetchTotal()
                        self.isAnimating = false
                    }
                case .failure(let error):
                    print("Error fetching receipts, clients, and categories: \(error)")
                    DispatchQueue.main.async {
                        self.isAnimating = false
                    }
                }
            }
        }
    }
}

struct ReceiptMainView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptMainView()
    }
}

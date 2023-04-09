import SwiftUI

struct ClientMainView: View {
    @Binding var selectedClient: (name: String, id: String)
    @Binding var isPresented: Bool
    
    @State private var showAddClientView = false
    @State private var clients: [Client] = []
    @State private var isAnimating: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                BannerContainerView()
                HStack {
                    Text("Client Tracker")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 50)

                    Spacer()

                    AdButton(onButtonAction: {
                        showAddClientView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20) // Add custom padding to create a gap between the button and the right edge
                    .fullScreenCover(isPresented: $showAddClientView) {
                        AddClientView(isPresented: $showAddClientView)
                            .onDisappear(perform: fetchClients)
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        ForEach(clients) { client in
                            AdButton(onButtonAction: {
                                selectedClient = (name: client.name, id: client.id)
                                    isPresented = false
                            }) {
                                ClientView(client: client)
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
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchClients)
            }
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
    }

    func fetchClients() {
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
            ClientService().fetchClientsByUserId(userId: userId, authToken: token) { result in
                switch result {
                case .success(let fetchedClients):
                    DispatchQueue.main.async {
                        self.clients = fetchedClients
                        self.isAnimating = false
                        print("Clients: \(self.clients)")
                    }
                case .failure(let error):
                    print("Error fetching clients: \(error)")
                    DispatchQueue.global(qos: .background).async {
                        self.isAnimating = false
                    }
                }
            }
        }
    }
}

struct ClientMainView_Previews: PreviewProvider {
    @State static private var selectedClient = (name: "", id: "")
    @State static private var isPresented = true
    
    static var previews: some View {
        ClientMainView(selectedClient: $selectedClient, isPresented: $isPresented)
    }
}

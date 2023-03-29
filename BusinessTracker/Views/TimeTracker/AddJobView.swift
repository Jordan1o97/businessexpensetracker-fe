import SwiftUI

struct AddJobView: View {
    @Binding var isPresented: Bool
        
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    @State private var income: String = ""
    @State private var rate: String = ""
    @State private var job: String = ""
    @State private var client: (name: String, id: String) = ("", "")
    @State private var task: String = ""
    @State private var notes: String = ""
    @State private var isLoading: Bool = false
    @State private var showClientMainView = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    var editMode: Bool = false // Set this to true when editing an existing job

    var canSave: Bool {
        return !income.isEmpty && !job.isEmpty && !client.id.isEmpty && !task.isEmpty
    }

    func saveJob() {
        isLoading = true

        let jobId = editMode ? UUID().uuidString : "" // Replace with the existing job ID when in edit mode
        let newJob = Job(id: jobId, start: start, end: end, rate: Double(income) ?? 0.0, income: Double(income) ?? 0.0, project: job, clientId: client.id, taskId: task, notes: notes, userId: "") // Replace userId with the actual userId"
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }

        JobService().createJob(job: newJob, authToken: token) { result in
            DispatchQueue.global(qos: .background).async {
                isLoading = false
                switch result {
                case .success(let job):
                    print("Job saved: \(job)")
                    isPresented = false
                case .failure(let error):
                    print("Error saving job: \(error)")
                }
            }
        }
        isPresented = false;
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
                    
                    Text(editMode ? "Edit Job" : "New Job")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    AdButton(onButtonAction: {
                        saveJob()
                    }) {
                        Text("Save")
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)
                
                Form {
                    Section {
                        HStack {
                            Text("Start:")
                            DatePicker("Start", selection: $start, displayedComponents: [.date, .hourAndMinute])
                        }
                        HStack {
                            Text("End:")
                            DatePicker("End", selection: $end, displayedComponents: [.date, .hourAndMinute])
                        }
                        HStack {
                            Text("Income:")
                            TextField("25.00", text: $income)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Rate:")
                            TextField("10.00", text: $rate)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Project:")
                            TextField("App Development", text: $job)
                        }
                        HStack {
                            Text("Client:")
                            Button(action: {
                                showClientMainView.toggle()
                            }) {
                                Text(client.name.isEmpty ? "Apple" : "\(client.name)")
                                    .foregroundColor(client.name.isEmpty ? .gray : .primary)
                            }
                            .sheet(isPresented: $showClientMainView) {
                                ClientMainView(selectedClient: $client, isPresented: $showClientMainView)
                            }
                        }
                        HStack {
                            Text("Task:")
                            TextField("Developing", text: $task)
                        }
                        HStack {
                            Text("Notes:")
                            TextField("Hope you enjoy :)", text: $notes)
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
    }
}

struct AddJobView_Previews: PreviewProvider {
    static var previews: some View {
        AddJobView(isPresented: .constant(true))
    }
}

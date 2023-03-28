//
//  EditJobView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct EditJobView: View {
    @Binding var isPresented: Bool
    @State var job: Job
        
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    @State private var income: String = ""
    @State private var rate: String = ""
    @State private var jobName: String = ""
    @State private var client: (name: String, id: String) = ("", "")
    @State private var task: String = ""
    @State private var notes: String = ""
    @State private var isLoading: Bool = false
    @State private var showClientMainView = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    var canSave: Bool {
        return !income.isEmpty && !jobName.isEmpty && !client.id.isEmpty && !task.isEmpty
    }

    func saveJob() {
        isLoading = true

        let jobId = job.id // Use the existing job ID when in edit mode
        let updatedJob = Job(id: jobId, start: start, end: end, rate: Double(rate) ?? 0.0, income: Double(income) ?? 0.0, project: jobName, clientId: client.id, taskId: task, notes: notes, userId: "") // Replace userId with the actual userId"
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }

        JobService().updateJob(job: updatedJob, authToken: token) { result in
            DispatchQueue.global(qos: .background).async {
                isLoading = false
                switch result {
                case .success(let job):
                    print("Job saved: \(job)")
                    isPresented = false
                case .failure(let error):
                    print("Error saving job: \(error)")
                    isLoading = false
                }
            }
        }
        isPresented = false;
    }
    
    func fetchClientName(clientId: String) {
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        isLoading = true
        
        ClientService().fetchClientById(clientId: clientId, authToken: token) { result in
            DispatchQueue.global(qos: .background).async {
                isLoading = false
                switch result {
                case .success(let client):
                    self.client = (name: client.name, id: client.id)
                case .failure(let error):
                    print("Error fetching client name: \(error)")
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
                    
                    Text("Edit Job")
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
                            DatePicker("Start", selection: $start, displayedComponents: .date)
                        }
                        HStack {
                            Text("End:")
                            DatePicker("End", selection: $end, displayedComponents: .date)
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
                            TextField("App Development", text: $jobName)
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
        .onAppear(){
            self.start = job.start
            self.end = job.end ?? Date()
            self.income = String(job.income)
            self.rate = String(job.rate)
            self.jobName = job.project
            fetchClientName(clientId: job.clientId)
            self.task = job.taskId
            self.notes = job.notes
        }
    }
}

struct EditJobView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleJob = Job(id: "51dKlxGX0HPJLycj98pc",
                            start: Date(timeIntervalSince1970: 1679039622),
                            end: nil,
                            rate: 150.0,
                            income: 300.0,
                            project: "Project 2",
                            clientId: "c7852d88-aa90-4386-9671-839970522468",
                            taskId: "Task 2",
                            notes: "Notes 2",
                            userId: "a5eb239d-93b8-438a-a947-f817796ae6b6")
        EditJobView(isPresented: .constant(true), job: sampleJob)
    }
}


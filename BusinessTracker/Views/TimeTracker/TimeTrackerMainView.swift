import SwiftUI

struct TimeTrackerMainView: View {
    @State private var selectedFilter: Int = 0
    @State private var showAddJobView = false
    @State private var jobs: [Job] = []
    @State private var clientNames: [String: String] = [:]
    @State private var isAnimating: Bool = false
    @State private var groupedJobs: [(String, [Job])] = []
    @State private var isEditViewPresented = false
    @State private var selectedJob: Job?
    
    private let filterTitles = ["Day", "Month", "Year", "Job", "Client"]
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                BannerContainerView()
                HStack {
                    Text("Time Tracker")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 50)

                    Spacer()

                    AdButton(onButtonAction: {
                        showAddJobView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20) // Add custom padding to create a gap between the button and the right edge
                    .fullScreenCover(isPresented: $showAddJobView) {
                        AddJobView(isPresented: $showAddJobView)
                            .onDisappear(perform: fetchJobs)
                    }
                }
                .padding(.horizontal)
                
                FilterBarView(filterTitles: filterTitles, selectedFilter: $selectedFilter)
                    .frame(width: UIScreen.main.bounds.width, height: 50)
                    .padding(.top, 16)
                    .onChange(of: selectedFilter) { _ in
                        fetchJobs()
                    }
                
                ScrollView {
                    VStack {
                        ForEach(groupedJobs, id: \.0) { group in
                            Text(getGroupHeader(group: group))
                                .font(.system(size: 18, weight: .bold))
                                .padding(.top)

                            ForEach(group.1) { job in
                                if let clientName = clientNames[job.clientId] {
                                    AdButton(onButtonAction: {
                                        selectedJob = job
                                        isEditViewPresented = true
                                    }) {
                                        JobView(job: job, clientName: clientName)
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
                    }
                }
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchJobs)
                .fullScreenCover(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 })) {
                    EditJobView(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 }), job: selectedJob!)
                        .onDisappear(perform: fetchJobs)
                }
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
    
    func getGroupHeader(group: (String, [Job])) -> String {
        if selectedFilter == 0 { // If the Day filter is selected
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            if let date = dateFormatter.date(from: group.0) {
                dateFormatter.dateFormat = "MMMM d, yyyy"
                return dateFormatter.string(from: date)
            }
        }
        return group.0
    }
    func fetchJobs() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        self.isAnimating = true

        JobService().fetchFilteredJobsAndClients(userId: userId, authToken: token, selectedFilter: selectedFilter) { result in
            switch result {
                case .success(let (groupedJobs, clientNames)):
                    DispatchQueue.main.async {
                        let sortedGroupedJobs = groupedJobs.map { (key, jobs) -> (String, [Job]) in
                            if selectedFilter == 1 || selectedFilter == 2 || selectedFilter == 3 {
                                let groupedJobs = jobs.sorted(by: { $0.start.compare($1.start) == .orderedDescending })
                                return (key, groupedJobs)
                            } else {
                                return (key, jobs)
                            }
                        }
                        self.jobs = groupedJobs.flatMap { $0.1 } // Flatten the array of jobs
                        self.clientNames = clientNames
                        self.groupedJobs = groupedJobs
                        self.isAnimating = false
                        print("groupedJobs: \(self.groupedJobs)")
                        print("Clients: \(self.clientNames)")
                    }
            case .failure(let error):
                print("Error fetching jobs and clients: \(error)")
                DispatchQueue.main.async {
                    self.isAnimating = false
                }
            }
        }
    }
}

struct TimeTrackerMainView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTrackerMainView()
    }
}

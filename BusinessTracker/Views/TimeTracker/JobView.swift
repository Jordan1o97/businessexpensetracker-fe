import SwiftUI

struct JobView: View {
    var job: Job
    var clientName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(job.project)
                .font(.headline)
            
            Divider()
            
            HStack {
                Text(clientName)
                    .font(.subheadline)
                Spacer()
                Text("Income: $\(job.income, specifier: "%.2f")")
                    .font(.subheadline)
            }
            
            Text("Start: \(job.start ?? Date(), formatter: DateFormatter.shortDateTime)")
                .font(.footnote)
            
            if let end = job.end {
                Text("End: \(end, formatter: DateFormatter.shortDateTime)")
                    .font(.footnote)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct JobView_Previews: PreviewProvider {
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
        let clientName = "John Doe"
        
        JobView(job: sampleJob, clientName: clientName)
    }
}

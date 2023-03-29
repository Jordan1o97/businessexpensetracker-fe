import SwiftUI

struct TripLogView: View {
    var tripLog: TripLog
    var clientName: String
    var vehicleName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(tripLog.date, formatter: DateFormatter.shortDate)")
                .font(.headline)

            Divider()

            HStack {
                Text(clientName)
                    .font(.subheadline)
                Spacer()
                Text("Destination: \(tripLog.destination)")
                    .font(.subheadline)
            }

            HStack {
                Text(vehicleName)
                    .font(.subheadline)
                Spacer()
                Text("Rate: $\(tripLog.rate, specifier: "%.2f")")
                    .font(.subheadline)
            }

            Text("Total: $\(tripLog.total, specifier: "%.2f")")
                .font(.footnote)

        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct TripLogView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTripLog = TripLog(id: "51dKlxGX0HPJLycj98pc",
                                    date: Date(timeIntervalSince1970: 1679039622),
                                    expense: 50.0,
                                    start: Date(timeIntervalSince1970: 1679039622),
                                    end: Date(timeIntervalSince1970: 1679039622),
                                    totalHours: 8,
                                    rate: 150.0,
                                    total: 300.0,
                                    vehicle: "Vehicle 1",
                                    origin: "Origin 1",
                                    destination: "Destination 1",
                                    clientId: "c7852d88-aa90-4386-9671-839970522468",
                                    notes: "Notes 1")

        let clientName = "John Doe"
        let vehicleName = "Vehicle 1"

        TripLogView(tripLog: sampleTripLog, clientName: clientName, vehicleName: vehicleName)
    }
}

import SwiftUI

struct ReceiptView: View {
    var receipt: Receipt
    var clientName: String
    var categoryName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total: $\(receipt.initalTotal + receipt.tip + receipt.tax, specifier: "%.2f")")
                .font(.headline)

            Divider()

            Text("Client: \(clientName)")
                .font(.subheadline)
            Text("Category: \(categoryName)")
                .font(.subheadline)
            Spacer()
            
            Text("Date: \(receipt.date, formatter: DateFormatter.shortDate)")
                .font(.subheadline)

            Text("Total: $\(receipt.initalTotal + receipt.tip + receipt.tax, specifier: "%.2f")")
                .font(.subheadline)

            Text("Status: \(receipt.status ?? "N/A")")
                .font(.footnote)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleReceipt = Receipt(id: "51dKlxGX0HPJLycj98pc",
                                    category: "Dining",
                                    date: Date(timeIntervalSince1970: 1679039622),
                                    initalTotal: 50.0,
                                    tax: 5.0,
                                    tip: 10.0,
                                    clientId: "c7852d88-aa90-4386-9671-839970522468",
                                    paymentMode: "Credit Card",
                                    description: "Business dinner",
                                    status: "Paid")

        let clientName = "John Doe"
        let categoryName = "Dining"

        ReceiptView(receipt: sampleReceipt, clientName: clientName, categoryName: categoryName)
    }
}

//
//  PDFPreviewView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    var pdfData: Data
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            PDFKitView(data: pdfData)
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true)
                }
            }) {
                Text("Share")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)
            Spacer()
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
    }
}

import Foundation
import Vision
import VisionKit

final class DocumentCameraDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
    var resultHandler: (([String: Any]) -> Void)?

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.imageOfPage(at: 0)
            let request = VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      error == nil else {
                    print("Error recognizing text: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let total = self?.findTotal(from: observations)
                let taxes = self?.findTaxes(from: observations)
                let tip = self?.findTip(from: observations)
                let paymentMode = self?.findPaymentMode(from: observations)

                let resultDict = ["total": total ?? 0.0,
                                  "taxes": taxes ?? 0.0,
                                  "tip": tip ?? 0.0,
                                  "paymentMode": paymentMode ?? ""]

                self?.resultHandler?(resultDict)
            })

            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])

            do {
                try handler.perform([request])
            }
            catch {
                print("Error recognizing text: \(error.localizedDescription)")
            }

            controller.dismiss(animated: true, completion: nil)
        }

    private func findTotal(from observations: [VNRecognizedTextObservation]) -> Double? {
        for observation in observations {
            guard let text = observation.topCandidates(1).first?.string else { continue }

            if text.contains("total") {
                return Double(text.replacingOccurrences(of: "total", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        return nil
    }

    private func findTaxes(from observations: [VNRecognizedTextObservation]) -> Double? {
        for observation in observations {
            guard let text = observation.topCandidates(1).first?.string else { continue }

            if text.contains("taxes") {
                return Double(text.replacingOccurrences(of: "taxes", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        return nil
    }

    private func findTip(from observations: [VNRecognizedTextObservation]) -> Double? {
        for observation in observations {
            guard let text = observation.topCandidates(1).first?.string else { continue }

            if text.contains("tip") {
                guard let tipString = text.replacingOccurrences(of: "tip", with: "").trimmingCharacters(in: .whitespacesAndNewlines) as String? else { continue }
                if let tip = Double(tipString) {
                    return (tip * 100).rounded() / 100
                }
            }
        }
        return nil
    }

    private func findPaymentMode(from observations: [VNRecognizedTextObservation]) -> String? {
        let keywords = ["cash", "credit", "debit", "check", "paypal", "venmo", "apple pay", "google pay", "bitcoin"]
        for observation in observations {
            guard let text = observation.topCandidates(1).first?.string else { continue }
            let lowercasedText = text.lowercased()

            for keyword in keywords {
                if lowercasedText.contains(keyword) {
                    return keyword.capitalized
                }
            }
        }

        return nil
    }
}

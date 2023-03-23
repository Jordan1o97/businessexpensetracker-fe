import SwiftUI
import Vision
import VisionKit

struct ScannerView: View {
    @Binding var result: String
//    @State private var result: String = ""
    //let documentCameraDelegate = DocumentCameraDelegate()
    
    var body: some View {
        VStack {
            Text(result)
                .padding()
//            Button(action: {
//                let scannerViewController = VNDocumentCameraViewController()
//                scannerViewController.delegate = self.documentCameraDelegate
//                self.documentCameraDelegate.resultHandler = { result in
//                    print(result)
//                    self.result = result
//                    self.isPresentingScanner.toggle() //dismiss scanner view
//                }
//                UIApplication.shared.windows.first?.rootViewController?.present(scannerViewController, animated: true)
//            }, label: {
//                Text("Scan Receipt")
//                    .padding()
//            })
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(result: .constant("Hello"))
    }
}

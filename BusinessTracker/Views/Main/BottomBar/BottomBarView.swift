//
//  BottomBarView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-13.
//

import SwiftUI
import VisionKit
import GoogleMobileAds

struct BottomBarView: View {
    @Binding var activeTab: ViewType
    @State private var isPresentingScanner = false
    @State private var isPresentingAddReceiptView = false
    @State private var result: String = ""
    @State private var scannedReceiptData: [String: Any] = [:]
    let documentCameraDelegate = DocumentCameraDelegate()
    
    @Environment(\.colorScheme) var colorScheme

    private func rootView() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return nil
        }

        return scene.windows.first?.rootViewController
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                HStack(){
                    TabBarButtonView(imageName: "doc.text.fill", title: "Receipts", isActive: activeTab == .receipts) {
                            activeTab = .receipts
                        }
                    
                        TabBarButtonView(imageName: "car.fill", title: "Mileage", isActive: activeTab == .triplog) {
                            activeTab = .triplog
                        }

                        Spacer()
                            .frame(width: 95)

                        TabBarButtonView(imageName: "clock.fill", title: "Tracker", isActive: activeTab == .timesheet) {
                            activeTab = .timesheet
                        }

                        TabBarButtonView(imageName: "gearshape.fill", title: "Settings", isActive: activeTab == .settings) {
                            activeTab = .settings
                        }
                }.padding(.bottom, 20)
            }
            .frame(minWidth: 400, minHeight: 75, maxHeight: 100)
            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            .padding(.horizontal)
            .cornerRadius(22.5)
        }
        .background(colorScheme == .dark ? Color(.systemGray4) : Color(red: 0.97, green: 0.97, blue: 0.97))
        .overlay(
            Button(action: {
                let scannerViewController = VNDocumentCameraViewController()
                scannerViewController.delegate = self.documentCameraDelegate
                self.documentCameraDelegate.resultHandler = { result in
                    print(result)
                    self.scannedReceiptData = result
                    self.isPresentingScanner.toggle() //dismiss scanner view
                    self.isPresentingAddReceiptView = true
                }
                rootView()?.present(scannerViewController, animated: true)
            }, label: {
                Circle()
                        .frame(width: 50, height: 100)
                        .foregroundColor(.blue)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 35, height: 25)
                                .foregroundColor(.white) // set foreground color to gray
                        )
                        .padding(.horizontal, 12)
                        .shadow(radius: 4)
            })
            .padding(.bottom, 15),
            alignment: .bottom
        )
        .sheet(isPresented: $isPresentingAddReceiptView) {
            AddReceiptView(isPresented: $isPresentingAddReceiptView, scannedReceiptData: $scannedReceiptData)
        }
        .edgesIgnoringSafeArea(.bottom) // ignore safe area for bottom edge
        .frame(maxWidth: .infinity) // fill width
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(activeTab: .constant(.receipts))
    }
}

//
//  CustomActionButton.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-14.
//

import SwiftUI

enum CustomButtonState {
    case normal
    case error
}

struct CustomActionButton: View {
    @Binding var buttonState: CustomButtonState
    var buttonText: String
    var errorText: String
    var requiredFields: [String]
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if requiredFields.allSatisfy({ !$0.isEmpty }) {
                buttonState = .normal
                action()
            }
        }) {
            Text(buttonState == .normal ? buttonText : errorText)
                .font(.custom("Urbanist", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 380, height: 60)
                .background(buttonState == .normal ? Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)) : Color.red)
                .cornerRadius(41)
        }
        .disabled(requiredFields.contains(where: { $0.isEmpty }))
        .opacity(requiredFields.allSatisfy({ !$0.isEmpty }) ? 1 : 0.5)
    }
}

//
//  TabBarButtonView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-13.
//

import SwiftUI

struct TabBarButtonView: View {
    let imageName: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action, label: {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24) // Set a fixed height for the images
                    .foregroundColor(isActive ? Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)) : (colorScheme == .dark ? .white : .gray))
                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)) : (colorScheme == .dark ? .white : .gray))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        })
    }
}

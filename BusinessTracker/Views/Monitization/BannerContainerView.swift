//
//  BannerContainerView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-23.
//

import SwiftUI

struct BannerContainerView: View {
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    var body: some View {
        if(accountType == "free"){
            BannerView(adUnitID: "ca-app-pub-9324761796430059/9535673072")
                .frame(maxHeight: 50)
                .padding(.top, 50)
        }else{
            Spacer().frame(maxHeight: 50)
        }
    }
}

struct BannerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerContainerView()
    }
}

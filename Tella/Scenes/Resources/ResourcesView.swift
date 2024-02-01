//
//  ResourcesView.swift
//  Tella
//
//  Created by gus valbuena on 1/31/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourcesView: View {
    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    // downloaded title
                    VStack {
                        sectionTitle(text: "Downloaded")
                    // downloaded card
                        downloadedCard(title: "Digital Security tips", subtitle: "Cleen foundation")
                        downloadedCard(title: "Important Contact Info", subtitle: "Cleen foundation")
                    }.padding(.bottom, 12)
                    
                    // download title
                    VStack {
                        sectionTitle(text: "Available for download")
                        sectionMessage(text: "These are the resources available for download from your Tella Web project(s).")
                    }
                    // download card
                    availableForDownloadCard(title: "Important Contact Info", subtitle: "Cleen foundation")
                    
                    Spacer()
                }.padding(.all, 18)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            LeadingTitleToolbar(title: "Resources")
            reloadButton(action: {})
        }
    }
    
    func sectionTitle(text: String) -> some View {
        return Text(text)
            .foregroundColor(.white)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
            .fontWeight(.semibold)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func sectionMessage(text: String) -> some View {
        Text("These are the resources available for download from your Tella Web project(s).")
            .foregroundColor(.white)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .fontWeight(.regular)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func downloadedCard(title: String, subtitle: String) -> some View {
        VStack(spacing: 0) {
            HStack {
            MoreButtonView(imageName: "resources.pdf", action: {})
            ConnectionCardDetail(title: title, subtitle: subtitle)
                    Spacer()
            MoreButtonView(imageName: "reports.more", action: {})
                }.padding(.all, 8)
        }
        .customCardStyle()
    }
    
    func availableForDownloadCard(title: String, subtitle: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                MoreButtonView(imageName: "resources.pdf", action: {})
                ConnectionCardDetail(title: title, subtitle: subtitle)
                Spacer()
                MoreButtonView(imageName: "save-icon", action: {})
            }.padding(.all, 8)
        }
        .customCardStyle()
    }
}

#Preview {
    ResourcesView()
}

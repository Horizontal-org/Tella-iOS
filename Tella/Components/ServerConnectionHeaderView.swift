//
//  ServerConnectionHeaderView.swift
//  Tella
//
//  Created by gus valbuena on 5/29/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ServerConnectionHeaderView: View {
    
    var title: String
    var subtitle: String
    var imageIconName: String
    var subtitleTextAlignment: TextAlignment = .center
    
    var body: some View {
        VStack(spacing: 8) {
            
            Image(imageIconName)
                .padding(.bottom, 16)
            
            CustomText(title,style: .heading1Style,
                       alignment: .center)
            
            CustomText(subtitle,
                       style: .body1Style,
                       alignment: subtitleTextAlignment)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ServerConnectionHeaderView(title: "title", subtitle: "subtitle", imageIconName: "gdrive.icon")
}

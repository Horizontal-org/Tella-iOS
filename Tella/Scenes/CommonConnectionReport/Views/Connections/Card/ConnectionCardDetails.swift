//
//  ConnectionCardDetail.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ConnectionCardDetailsView: View {
    var title : String
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            CustomText(title, style: .subheading1Style)
                .lineLimit(1)
            
            if let subtitle {
                
                CustomText(subtitle, style: .body2Style)
            }
        }
    }
}

struct ReportCardDetail_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionCardDetailsView(title: "Title", subtitle: "Subtitle")
            .background(Styles.Colors.backgroundTab)
    }
}

//
//  ConnectionCardDetail.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ConnectionCardDetail: View {
    var title : String
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
                .lineLimit(1)
            if (subtitle != nil) {
                Text(subtitle!)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}

struct ReportCardDetail_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionCardDetail(title: "", subtitle: "")
    }
}

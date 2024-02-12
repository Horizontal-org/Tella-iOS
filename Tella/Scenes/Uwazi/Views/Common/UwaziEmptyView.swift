//
//  UwaziEmptyView.swift
//  Tella
//
//  Created by Gustavo on 21/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziEmptyView: View {
    var message : String
    
    var body: some View {
        VStack(alignment: .center, spacing: 22) {
            Image("uwazi.empty")
            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(EdgeInsets(top: 0, leading: 31, bottom: 0, trailing: 31))
    }
}

struct UwaziEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            EmptyReportView(message: LocalizableReport.reportsDraftEmpty.localized)
        }
    }
}

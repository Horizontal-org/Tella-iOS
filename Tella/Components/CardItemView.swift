//
//  CardItemView.swift
//  Tella
//
//  Created by RIMA on 10.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CardItemView: View {
    
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            CustomText(title,
                           style: .body1Font)
            Spacer()
            CustomText(subtitle,
                           style: .body1Font)
        }.cardModifier()
            .frame(height: 53)
    }
}

#Preview {
    CardItemView(title: "Title", subtitle: "Subtitle")
}

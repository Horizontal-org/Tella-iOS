//
//  CardItemView.swift
//  Tella
//
//  Created by RIMA on 10.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CardItemView: View {
    
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            CustomText(title,
                           style: .body1Style)
            Spacer()
            CustomText(subtitle,
                           style: .body1Style)
        }.cardModifier()
            .frame(height: 53)
    }
}

#Preview {
    CardItemView(title: "Title", subtitle: "Subtitle")
}

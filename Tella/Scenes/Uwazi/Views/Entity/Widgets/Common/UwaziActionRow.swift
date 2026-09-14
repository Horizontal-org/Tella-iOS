//
//  UwaziActionRow.swift
//  Tella
//
//  Created by Gustavo on 24/10/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct UwaziActionRow: View {
    let icon: ImageResource
    let title: String
    
    var body: some View {
        HStack {
            Image(icon)
                .padding(.vertical, .smallMedium)
            CustomText(title,
                       style: .body1Style,
                       color: Color.white.opacity(0.80),
                       fillsWidth: true)
        }
        .padding(.horizontal, .normal)
        .background(Color.white.opacity(0.08))
        .cornerRadius(.smallCornerRadius)
    }
}

#Preview {
    VStack(spacing: 16) {
        UwaziActionRow(icon: .uwaziAddFiles, title: "Select files")
        UwaziActionRow(icon: .uwaziLocation, title: "Add location")
    }
    .padding()
    .background(Styles.Colors.backgroundMain)
}

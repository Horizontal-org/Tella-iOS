//
//  PageDots.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct PageDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(current == index ? Styles.Colors.yellow
                          : Styles.Colors.gray.opacity(0.6))
                    .frame(width: 10, height: 10)
            }
        }
    }
}

#Preview {
    PageDots(current: 1, total: 3)
}

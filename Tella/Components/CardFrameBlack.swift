//
//  CardFrameBlack.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CardFrameBlackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.all, .normal)
            .background(Color.black.opacity(0.4))
            .cornerRadius(.cornerRadius)
    }
}

extension View {
    func cardFrameBlackStyle() -> some View {
        self.modifier(CardFrameBlackModifier())
    }
}

//
//  CardFrame.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CardFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
             content
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 17, bottom: 6, trailing: 17))
     }
}

extension View {
    func cardFrameStyle() -> some View {
        self.modifier(CardFrameModifier())
    }
}

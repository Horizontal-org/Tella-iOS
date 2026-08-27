//
//  ToastViewBg.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ToastMessageView: View {
    var message: String
    
    var body: some View {
        CustomText(message, style: .body1Style, color: .black, fillsWidth: true)
            .padding(16)
            .background(Styles.Colors.backgroundToast, in: RoundedRectangle(cornerRadius: 4))
            .padding(16)
    }
}

#Preview {
    ToastMessageView(message: "Message")
}

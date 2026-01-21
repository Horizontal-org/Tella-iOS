//
//  NextBottomView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct NextBottomView: View {    
    var nextAction : (() -> Void)?
    
    var body: some View {
        HStack {
            Spacer()
            
            BottomButtonActionView(title: LocalizableLock.actionNext.localized,
                                   isValid: true) {
                self.nextAction?()
            }
        }
    }
}

#Preview {
    NextBottomView()
}

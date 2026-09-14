//
//  OnboardingSuccessLoginView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct SuccessLockView: View {
    var nextAction: () -> Void
    
    var body: some View {
        
        VStack(spacing: .normal) {
            Spacer()
            ImageTitleMessageView(content: SuccessLockContent())
            LinkView(url: TellaUrls.appLock, text: LocalizableLock.lockSuccessLink.localized)
            Spacer()
            NextBottomView(title: LocalizableLock.actionNext.localized) {
                nextAction()
            }
        }.padding(.horizontal, .medium)
            .containerStyle()
            .navigationBarHidden(true)
    }
}

#Preview {
    SuccessLockView {}
}

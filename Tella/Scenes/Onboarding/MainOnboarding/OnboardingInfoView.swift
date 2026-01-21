//
//  OnboardingInfoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OnboardingInfoView: View {
    
    let content: any ImageTitleMessageContent
    let info: String

    var body: some View {
        VStack(spacing: .large) {
            ImageTitleMessageView(content: content)
            infoView
        }.padding(.horizontal, .medium)
    }
    
    var infoView: some View {
        HStack(spacing: .extraSmall) {
            Image(.infoIcon)
            
            Text(info)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(.white)
        }.cardFrameBlackStyle()
    }
}

#Preview {
    OnboardingInfoView(content: RecordContent(), info: LocalizableLock.onboardingRecordInfo.localized)
}

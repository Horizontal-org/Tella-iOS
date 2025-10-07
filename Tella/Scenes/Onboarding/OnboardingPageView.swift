//
//  OnboardingPageView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OnboardingPageView: View {
    
    let content: any OnboardingContent
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 16) {
            
            Image(content.imageName)
            
            Text(content.title)
                .font(.custom(Styles.Fonts.boldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(content.message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(.horizontal, 25)
    }
}

#Preview {
    OnboardingPageView(content: CameraContent())
}

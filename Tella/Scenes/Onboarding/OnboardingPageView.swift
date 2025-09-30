//
//  OnboardingPageView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct OnboardingPageView: View {
    
    let imageName: ImageResource
    let title: String
    let message: String
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            Image(imageName)
            
            Text(title)
                .font(.custom(Styles.Fonts.boldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }
}

//#Preview {
//    OnboardingView(viewModel: OnboardingViewModel())
//}

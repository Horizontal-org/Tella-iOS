//
//  AdvancedCustomizationCompleteView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct AdvancedCustomizationCompleteView: View {
    
    var appViewState: AppViewState
    
    var body: some View {
        
        VStack(spacing: 50) {
            Spacer()
            
            OnboardingPageView(content: AdvancedCustomizationComplete())
            
            TellaButtonView<AnyView> (title: LocalizableLock.goToTella.localized.uppercased(),
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: .constant(true)) {
                self.appViewState.resetToMain()
            }
            Spacer()
        }.padding(.horizontal,25)
    }
}


#Preview {
    AdvancedCustomizationCompleteView(appViewState: AppViewState.stub())
}

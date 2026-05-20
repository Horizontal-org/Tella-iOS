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
        
        VStack(spacing: .extraLarge) {
            Spacer()
            
            ImageTitleMessageView(content: AdvancedCustomizationComplete())
            
            TellaButtonView(title: LocalizableLock.goToTella.localized.uppercased(),
                            nextButtonAction: .action,
                            buttonType: .yellow,
                            isValid: .constant(true)) {
                self.appViewState.resetToMain()
            }
            Spacer()
        }.padding(.horizontal,.medium)
    }
}


#Preview {
    AdvancedCustomizationCompleteView(appViewState: AppViewState.stub())
}

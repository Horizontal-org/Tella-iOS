//
//  OnboardingSuccessLoginView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OnboardingSuccessLoginView: View {
    var body: some View {
      
        VStack(spacing: 50) {
            Spacer()

            OnboardingPageView(content: SuccessLockContent())
            Image(.settingsCheckedCircle)
            Spacer()
        }
    }
}


struct ServerConnectedSuccessView: View {
    var body: some View {
      
        VStack(spacing: 50) {
            Spacer()

            OnboardingPageView(content: ServerConnectedContent())
            Image(.settingsCheckedCircle)
            Spacer()
        }
    }
}


#Preview {
    OnboardingSuccessLoginView()
}

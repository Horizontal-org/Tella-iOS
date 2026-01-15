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
        
        VStack(spacing: .extraLarge) {
            Spacer()
            ImageTitleMessageView(content: SuccessLockContent())
            Image(.settingsCheckedCircle)
            Spacer()
        }.padding(.horizontal, .medium)
    }
}


struct ServerConnectedSuccessView: View {
    var body: some View {
        
        VStack(spacing: .extraLarge) {
            Spacer()
            ImageTitleMessageView(content: ServerConnectedContent())
            Image(.settingsCheckedCircle)
            Spacer()
        }.padding(.horizontal, .medium)
    }
}


#Preview {
    OnboardingSuccessLoginView()
}

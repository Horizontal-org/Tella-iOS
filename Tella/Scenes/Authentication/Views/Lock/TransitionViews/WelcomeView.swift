//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct WelcomeView: View {
    var appViewState: AppViewState

    @StateObject private var mainOnboardingViewModel: MainOnboardingViewModel

    init(appViewState: AppViewState) {
        self.appViewState = appViewState

        let lockViewModel = LockViewModel(lockFlow: .new, appViewState: appViewState)
        _mainOnboardingViewModel = StateObject(
            wrappedValue: MainOnboardingViewModel(lockViewModel: lockViewModel)
        )
    }
    
    var body: some View {
        NavigationContainerView {
            MainOnboardingView(viewModel: mainOnboardingViewModel)
        }
    }
}

#Preview {
    WelcomeView(appViewState: AppViewState.stub())
}

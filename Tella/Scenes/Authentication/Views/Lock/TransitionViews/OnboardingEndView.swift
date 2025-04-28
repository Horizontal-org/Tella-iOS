//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct OnboardingEndView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: OnboardingEndViewData()) {
                self.appViewState.resetToMain()
            }
        }
    }
}

struct OnboardingEndView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingEndView()
    }
}

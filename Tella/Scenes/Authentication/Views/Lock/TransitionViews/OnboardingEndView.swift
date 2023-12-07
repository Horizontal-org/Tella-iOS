//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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

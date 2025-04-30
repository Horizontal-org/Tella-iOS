//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct WelcomeView: View {
    
    @State var shouldShowLockChoice : Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: WelcomeViewData()) {
                shouldShowLockChoice = true
                navigateTo(destination: LockChoiceView())
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

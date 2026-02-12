//
//  LockChoiceOnboardingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct LockChoiceOnboardingView: View {
    
    var lockViewModel : LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationContainerView {
            VStack {
                
                LockChoiceView(lockViewModel: lockViewModel)
                
                BackBottomView {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.navigationBarHidden(true)
    }
}

#Preview {
    LockChoiceOnboardingView(lockViewModel: LockViewModel.stub())
}

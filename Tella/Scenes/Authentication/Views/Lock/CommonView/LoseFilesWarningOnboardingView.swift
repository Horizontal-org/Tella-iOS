//
//  OnboardingWarningView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct LoseFilesWarningOnboardingView: View {
    
    var lockViewModel : LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ContainerView {
            VStack() {
                
                VStack(spacing: .extraLarge) {
                    Spacer()
                    
                    ImageTitleMessageView(content: LoseFilesWarningOnboardingContent())
                    
                    TellaButtonView(title: LocalizableLock.loseFileWarningUnderstand.localized.uppercased(),
                                              nextButtonAction: .action,
                                              buttonType: .clear,
                                              isValid: .constant(true)) {
                        
                        switch lockViewModel.lockType {
                        case .pin:
                            self.navigateTo(destination: LockPinView(lockViewModel:lockViewModel))
                            
                        case .password:
                            self.navigateTo(destination: LockPasswordView(lockViewModel:lockViewModel))
                        default:
                            break
                        }
                    }
                    
                    Spacer()
                }.padding(.horizontal,.medium)
                
                BackBottomView {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        }.navigationBarHidden(true)
    }
}

#Preview {
    LoseFilesWarningOnboardingView(lockViewModel: LockViewModel.stub())
}

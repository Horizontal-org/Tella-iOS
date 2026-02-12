//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct LockConfirmPinView: View {
    
    @ObservedObject var lockViewModel: LockViewModel
    @State var shouldShowErrorMessage : Bool = false
    
    var body: some View {
        ZStack {
            CustomPinView(lockViewData: LockConfirmPinData(),
                          nextButtonAction: .action,
                          fieldContent: $lockViewModel.confirmPassword,
                          shouldShowErrorMessage: $shouldShowErrorMessage,
                          destination: EmptyView()) {
                
                if lockViewModel.shouldShowErrorMessage {
                    shouldShowErrorMessage = true
                } else {
                    showProtectLocksheet()
                }
            }
        }
    }
    
    func showProtectLocksheet() {
        let content = ConfirmBottomSheet(titleText: LocalizableLock.protectLocksheetTitle.localized,
                                         msgText: LocalizableLock.protectLocksheetExpl.localized,
                                         actionText: LocalizableLock.protectLocksheetAction.localized,
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            self.dismiss {
                lockViewModel.lockFlow == .new ? self.lockWithPin() : self.updatePin()
                
            }
            
        })
        
        showBottomSheetView(content: content)
    }
    
    func lockWithPin() {
        lockViewModel.initKeys(passwordTypeEnum: .tellaPin)
        
        self.navigateTo(destination: SuccessLockView())
        
        lockViewModel.shouldDismiss.send(true)
    }
    
    func updatePin() {
        lockViewModel.updateKeys(passwordTypeEnum: .tellaPin)
        lockViewModel.shouldDismiss.send(true)
    }
}

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView(lockViewModel: LockViewModel.stub())
    }
}

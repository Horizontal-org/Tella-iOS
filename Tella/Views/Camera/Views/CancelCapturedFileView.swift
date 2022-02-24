//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI


struct CancelCapturedFileView: View {
    
    @Binding var showingCancelImportConfirmationSheet : Bool
    @ObservedObject var appModel: MainAppModel
    
    let modalHeight = 152
    let didConfirm : (() -> Void)?
    let didCancel : (() -> Void)?
    
    var body: some View {
        ZStack{
            
            ConfirmBottomSheet(titleText: LocalizableCamera.cancelAddFileTitle.localized,
                               msgText: LocalizableCamera.cancelAddFileMessage.localized,
                               cancelText: LocalizableCamera.cancelAddFileBackButtonTitle.localized,
                               actionText: LocalizableCamera.cancelAddFileButtonTitle.localized,
                               modalHeight: 161,
                               isPresented: $showingCancelImportConfirmationSheet) {
                didConfirm?()
                
            } didCancelAction: {
                didCancel?()
            }
        }
    }
}

struct CancelAddFileView_Previews: PreviewProvider {
    static var previews: some View {
        CancelCapturedFileView(showingCancelImportConfirmationSheet: .constant(true), appModel: MainAppModel()) {
            
        } didCancel: {
            
        }
    }
}


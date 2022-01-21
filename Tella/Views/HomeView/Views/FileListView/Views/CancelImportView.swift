//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CancelImportView: View {
    
    @Binding var showingCancelImportConfirmationSheet : Bool
    @ObservedObject var appModel: MainAppModel
    
    let modalHeight = 152
    let didConfirm : (() -> Void)?
    let didCancel : (() -> Void)?
    
    var body: some View {
        ZStack{
            
            ConfirmBottomSheet(titleText: LocalizableHome.cancelImportFileTitle.localized,
                               msgText: LocalizableHome.cancelImportFileMessage.localized,
                               cancelText: LocalizableHome.cancelImportFileBack.localized,
                               actionText: LocalizableHome.cancelImportFileCancelImport.localized,
                               modalHeight: 161,
                               isPresented: $showingCancelImportConfirmationSheet) {
                didConfirm?()
                
            } didCancelAction: {
                didCancel?()
            }
        }
    }
}

struct CancelImportView_Previews: PreviewProvider {
    static var previews: some View {
        CancelImportView(showingCancelImportConfirmationSheet: .constant(true), appModel: MainAppModel()) {
            
        } didCancel: {
            
        }
    }
}

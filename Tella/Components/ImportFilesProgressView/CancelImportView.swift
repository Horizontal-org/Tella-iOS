//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CancelImportView: View {
    
    @Binding var showingCancelImportConfirmationSheet : Bool
    @ObservedObject var appModel: MainAppModel
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    
    let modalHeight = 152
    let didConfirm : (() -> Void)?
    let didCancel : (() -> Void)?
    
    var body: some View {
        ZStack{
            
            ConfirmBottomSheet(titleText: importFilesProgressProtocol.cancelTitle,
                               msgText: importFilesProgressProtocol.cancelMessage,
                               cancelText: Localizable.Common.back.uppercased(),
                               actionText: importFilesProgressProtocol.cancelButtonTitle,
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
        CancelImportView(showingCancelImportConfirmationSheet: .constant(true), appModel: MainAppModel(), importFilesProgressProtocol: ImportFilesProgress()) {
            
        } didCancel: {
            
        }
    }
}

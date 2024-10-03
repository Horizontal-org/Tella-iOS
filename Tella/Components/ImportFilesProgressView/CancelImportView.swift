//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CancelImportView: View {
    
    @EnvironmentObject var mainAppModel: MainAppModel
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    
    @EnvironmentObject var sheetManager: SheetManager
    @Binding var shouldShowView : Bool
    
    var body: some View {
        ZStack {
            ConfirmBottomSheet(titleText: importFilesProgressProtocol.cancelTitle,
                               msgText: importFilesProgressProtocol.cancelMessage,
                               cancelText: importFilesProgressProtocol.exitCancelImportButtonTitle,
                               actionText: importFilesProgressProtocol.cancelImportButtonTitle,
                               shouldHideSheet: false) {
                mainAppModel.vaultFilesManager?.cancelImportAndEncryption()
                shouldShowView = false
            } didCancelAction: {
                shouldShowView = false
            }.background(Styles.Colors.backgroundTab)
        }
    }
}
//
struct CancelImportView_Previews: PreviewProvider {
    static var previews: some View {
        CancelImportView( importFilesProgressProtocol: ImportFilesProgress(), shouldShowView: .constant(true))
    }
}

//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CancelImportView: View {
    
    @EnvironmentObject var mainAppModel: MainAppModel
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ZStack{
            ConfirmBottomSheet(titleText: importFilesProgressProtocol.cancelTitle,
                               msgText: importFilesProgressProtocol.cancelMessage,
                               cancelText: importFilesProgressProtocol.exitCancelImportButtonTitle,
                               actionText: importFilesProgressProtocol.cancelImportButtonTitle) {
                mainAppModel.vaultFilesManager?.cancelImportAndEncryption()
                sheetManager.hide()

            } didCancelAction: {
                sheetManager.hide()
            }
        }
    }
}
//
struct CancelImportView_Previews: PreviewProvider {
    static var previews: some View {
        CancelImportView( importFilesProgressProtocol: ImportFilesProgress())
    }
}

//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CancelImportView: View {
    
    @ObservedObject var mainAppModel: MainAppModel
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ZStack{
            ConfirmBottomSheet(titleText: importFilesProgressProtocol.cancelTitle,
                               msgText: importFilesProgressProtocol.cancelMessage,
                               cancelText: Localizable.Common.back.uppercased(),
                               actionText: importFilesProgressProtocol.cancelButtonTitle) {
                mainAppModel.vaultManager.progress.resume()
                mainAppModel.cancelImportAndEncryption()
                sheetManager.hide()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    mainAppModel.vaultManager.progress.stop()
                })
                
            } didCancelAction: {
                mainAppModel.vaultManager.progress.resume()
                sheetManager.hide()
            }
        }
    }
}

struct CancelImportView_Previews: PreviewProvider {
    static var previews: some View {
        CancelImportView( mainAppModel: MainAppModel(),
                          importFilesProgressProtocol: ImportFilesProgress())
    }
}

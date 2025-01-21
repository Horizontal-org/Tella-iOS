//
//  EditFileCancelBottomSheet.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct EditFileCancelBottomSheet: View {
    
    var saveAction: ()->()
    var cancelAction: ()->()
    
    var body: some View {
        ConfirmBottomSheet(titleText: LocalizableVault.editFileConfirmExitTitle.localized,
                           msgText: LocalizableVault.editFileConfirmExitExpl.localized,
                           cancelText: LocalizableVault.editFileExitSheetAction.localized,
                           actionText:LocalizableVault.renameFileSaveSheetAction.localized,
                           shouldHideSheet: false,
                           didConfirmAction: {
            self.dismiss {
                saveAction()
            }
        }, didCancelAction: {
            self.dismiss {
                cancelAction()
            }
        })
    }
}

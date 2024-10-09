//
//  EditFileCancelBottomSheet.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct EditFileCancelBottomSheet: View {
    @EnvironmentObject var sheetManager: SheetManager
    @Binding var isShown : Bool
    var saveAction: ()->()

    var body: some View {
        DragView(modalHeight: 171, isShown: $isShown) {
            ConfirmBottomSheet(titleText: LocalizableVault.editFileConfirmExitTitle.localized,
                               msgText: LocalizableVault.editFileConfirmExitExpl.localized,
                               cancelText: LocalizableVault.editFileExitSheetAction.localized,
                               actionText:LocalizableVault.renameFileSaveSheetAction.localized, didConfirmAction: {
                saveAction()
                Toast.displayToast(message: LocalizableVault.editFileSavedToast.localized)
            }, didCancelAction: {
                self.dismiss()
            })
        }
    }
}


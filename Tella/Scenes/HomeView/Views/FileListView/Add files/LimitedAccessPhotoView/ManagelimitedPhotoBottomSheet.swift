//
//  ManagelimitedPhotoBottomSheet.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Photos

struct ManagelimitedPhotoBottomSheet: View {
    
    let items : [ListActionSheetItem] = [ListActionSheetItem(imageName: "uwazi.add-files",
                                                             content: LocalizableVault.limitedPhotoLibraryAdd.localized,
                                                             type: LimitedPhotoLibraryActionType.add),
                                         ListActionSheetItem(imageName: "settings.general",
                                                             content: LocalizableVault.limitedPhotoLibraryChangePermission.localized,
                                                             type: LimitedPhotoLibraryActionType.settings) ]
    
    var body: some View {
        ActionListBottomSheet(items: items, headerTitle: LocalizableVault.limitedPhotoLibraryManageAccess.localized,
                              action:  {item in
            self.handleActions(item : item)
        })
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? LimitedPhotoLibraryActionType else { return }
        self.dismiss {
        switch type {
         case .add:
                showLimittedAccessUI()
        case .settings:
                self.changePhotoLibraryPermission()
            }
        }
    }
    
    func showLimittedAccessUI() {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: UIApplication.getTopViewController()!)
        }
    }
    
    func changePhotoLibraryPermission() {
        UIApplication.shared.openSettings()
    }
}

#Preview {
    ManagelimitedPhotoBottomSheet()
}

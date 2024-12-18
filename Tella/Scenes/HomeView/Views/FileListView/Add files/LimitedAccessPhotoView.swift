//
//  LimitedAccessPhotoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Photos

struct LimitedAccessPhotoView: View {
    
    @State private var showingLimitedPhotoPickerSheet : Bool = false
    
    var body: some View {
        ContainerView {
            content
        }
    }
    
    var content: some View {
        VStack() {
            CloseHeaderView(title: LocalizableVault.limitedPhotoLibraryAppBar.localized) {
                self.dismiss()
            }.frame(height: 45)
            
            
            cardButtonView
            
            EmptyFileView(message: LocalizableVault.limitedPhotoLibraryEmptyFiles.localized)
            
            Spacer()
        }
    }
    
    var cardButtonView: some View {
        CardButtonView(title: LocalizableVault.limitedPhotoLibraryTitle.localized,
                       description: LocalizableVault.limitedPhotoLibraryExpl.localized,
                       buttonTitle: LocalizableVault.limitedPhotoLibraryManage.localized,
                       action: {
            
            showManagelimitedPhotoBottomSheet()
            
        }).cardFrameStyle()
    }
    
    func showManagelimitedPhotoBottomSheet() {
        
        let items : [ListActionSheetItem] = [ListActionSheetItem(imageName: "uwazi.add-files",
                                                                 content: LocalizableVault.limitedPhotoLibraryAdd.localized,
                                                                 type: LimitedPhotoLibraryActionType.add),
                                             ListActionSheetItem(imageName: "settings.general",
                                                                 content: LocalizableVault.limitedPhotoLibraryChangePermission.localized,
                                                                 type: LimitedPhotoLibraryActionType.settings) ]
        
        let content = ActionListBottomSheet(items: items, headerTitle: LocalizableVault.limitedPhotoLibraryManageAccess.localized,
                                            action:  {item in
            self.handleActions(item : item)
        })
        
        self.showBottomSheetView(content: content, modalHeight: 195)
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? LimitedPhotoLibraryActionType else { return }
        
        switch type {
            
        case .add:
            self.dismiss {
                showLimittedAccessUI()
            }
        case .settings:
            self.dismiss {
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
    LimitedAccessPhotoView()
}


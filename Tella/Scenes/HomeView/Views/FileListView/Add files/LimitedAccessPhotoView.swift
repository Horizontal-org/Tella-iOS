//
//  LimitedAccessPhotoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct LimitedAccessPhotoView: View {

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
        }).cardFrameStyle()
    }
}

#Preview {
    LimitedAccessPhotoView()
}

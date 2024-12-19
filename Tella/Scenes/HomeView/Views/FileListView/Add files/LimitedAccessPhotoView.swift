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
    @StateObject var limitedAccessPhotoViewModel = LimitedAccessPhotoViewModel()
    
    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2.5), count: 4)
    }
    
    private var height: CGFloat {
        let totalSpacing = (16 * 2) + (2.5 * 3) // Padding and spacing between cells
        return (UIScreen.screenWidth - totalSpacing) / 4
    }
    
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
            
            if limitedAccessPhotoViewModel.assets.isEmpty {
                EmptyFileView(message: LocalizableVault.limitedPhotoLibraryEmptyFiles.localized)
            } else {
                limitedPhotosView
                
                Spacer()
                
                TellaButtonView<AnyView> (title: "Import selected",
                                          nextButtonAction: .action,
                                          buttonType: .clear,
                                          isValid: .constant(true)) {
                    
                    print(limitedAccessPhotoViewModel.assets.filter({$0.isSelected}).count)
                }
            }
            
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
    
    var limitedPhotosView: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 2.5) {
                ForEach(limitedAccessPhotoViewModel.assets, id: \.self) { file in
                    AssetGridView(assetItem: file)
                        .frame(height: height)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
    
    func showManagelimitedPhotoBottomSheet() {
        self.showBottomSheetView(content: ManagelimitedPhotoBottomSheet(), modalHeight: 195)
    }
}

#Preview {
    LimitedAccessPhotoView()
}


//
//  LimitedAccessPhotoView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/12/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Photos

struct LimitedAccessPhotoView: View {
    
    @State private var showingLimitedPhotoPickerSheet: Bool = false
    @StateObject var limitedAccessPhotoViewModel = LimitedAccessPhotoViewModel()
    
    var didSelect : ([PHAsset]) -> Void
    let kCellSpacing = 2.5
    
    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: kCellSpacing), count: 4)
    }
    
    private var height: CGFloat {
        let totalSpacing = (16 * 2) + (kCellSpacing * 3) // Padding and spacing between cells
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

            VStack(alignment: .leading, spacing: 16) {
                
                cardButtonView
                
                if limitedAccessPhotoViewModel.assets.isEmpty {
                    EmptyFileView(message: LocalizableVault.limitedPhotoLibraryEmptyFiles.localized)
                } else {
                    
                    DividerView()
                    
                    Text(LocalizableVault.limitedPhotoLibrarySelectExpl.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white.opacity(0.88))
                    
                    limitedPhotosView
                    
                    Spacer()
                }
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
            
            VStack(spacing: 0) {
                
                DividerView()
                
                TellaButtonView<AnyView> (title: LocalizableVault.limitedPhotoLibraryImport.localized,
                                          nextButtonAction: .action,
                                          buttonType: .clear,
                                          isValid: $limitedAccessPhotoViewModel.shouldEnableButton) {
                    didSelect(limitedAccessPhotoViewModel.selectedAssets)
                    self.dismiss()
                }.padding(.all, 16)
            }
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
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: kCellSpacing) {
                ForEach(limitedAccessPhotoViewModel.assets, id: \.self) { file in
                    AssetGridView(assetItem: file) {
                        limitedAccessPhotoViewModel.updateButtonState()
                    } .frame(height: height)
                }
            }
        }
    }
    
    func showManagelimitedPhotoBottomSheet() {
        self.showBottomSheetView(content: ManagelimitedPhotoBottomSheet())
    }
}

#Preview {
    LimitedAccessPhotoView { result in
        
    }
}


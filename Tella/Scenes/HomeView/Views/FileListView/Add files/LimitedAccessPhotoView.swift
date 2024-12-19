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
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(limitedAccessPhotoViewModel.assets, id: \.self) { asset in
                    Image(uiImage: getImageFromAsset(asset))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func getImageFromAsset(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        var image = UIImage()
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { img, info in
            if let img = img {
                image = img
            }
        }
        return image
    }

    func showManagelimitedPhotoBottomSheet() {
        self.showBottomSheetView(content: ManagelimitedPhotoBottomSheet(), modalHeight: 195)
    }
}

#Preview {
    LimitedAccessPhotoView()
}


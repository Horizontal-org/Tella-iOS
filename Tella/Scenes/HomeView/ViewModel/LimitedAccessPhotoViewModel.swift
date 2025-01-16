//
//  LimitedAccessPhotoViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Photos
import SwiftUI

class LimitedAccessPhotoViewModel: NSObject,ObservableObject,PHPhotoLibraryChangeObserver {
    
    @Published var assets: [AssetItem] = []
    @Published var shouldEnableButton: Bool = false

    var selectedAssets: [PHAsset] {
        return assets.filter({$0.isSelected}).compactMap({$0.file})
    }
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        fetchAssets()
    }
    
    // Handle changes in the photo library
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.fetchAssets()
        }
    }
    
    func fetchAssets() {
        let fetchResult = PHAsset.fetchAssets(with: nil)
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        
        self.assets = assets.compactMap({ AssetItem(file: $0, isSelected: false) })
        updateButtonState()
    }
    
    func updateButtonState() {
        shouldEnableButton = !selectedAssets.isEmpty
    }
}

//
//  AssetItem.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//
import Photos

class AssetItem: Hashable, ObservableObject {
    
    @Published var file: PHAsset
    @Published var isSelected: Bool
    
    init(file : PHAsset, isSelected : Bool) {
        self.file = file
        self.isSelected = isSelected
    }
    
    static func == (lhs: AssetItem, rhs: AssetItem) -> Bool {
        lhs.file == rhs.file
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
    
}

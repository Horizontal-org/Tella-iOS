//
//  AssetGridView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/12/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import Photos

struct AssetGridView: View {
    
    @ObservedObject var assetItem: AssetItem
    var didSelect: () -> Void
    
    var body: some View {
        
        GeometryReader { geometryReader in
            
            ZStack {
                
                Image(uiImage: assetItem.file.getImageFromAsset())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                
                selectingFilesView
                
            }.frame(width: geometryReader.size.width, height: geometryReader.size.height)
                .clipped()
                .onTapGesture {
                    selectItem()
                }
        }
    }
    
    var selectingFilesView: some View {
        
        GeometryReader { geometryReader in
            if assetItem.isSelected {
                Color.black.opacity(0.32)
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            }
            
            HStack() {
                
                VStack(alignment: .leading) {
                    Image(assetItem.isSelected ? "files.selected" : "files.unselected")
                        .frame(width: 25, height: 25)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                    Spacer()
                    
                }
                Spacer()
            }
        }
    }
    
    func selectItem()  {
        assetItem.isSelected.toggle()
        didSelect()
    }
}

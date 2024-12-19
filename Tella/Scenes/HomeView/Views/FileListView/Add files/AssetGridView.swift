//
//  AssetGridView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Photos

struct AssetGridView: View {
    
    var file: PHAsset
    
    var body: some View {
        
        GeometryReader { geometryReader in
            
            ZStack {
                
                Image(uiImage: file.getImageFromAsset())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                
                selectingFilesView
                
            } .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                .clipped()
            
        }
    }
    
    var selectingFilesView: some View {
        GeometryReader { geometryReader in
            
            Color.black.opacity(0.32)
                .onTapGesture {
                    // updateSelection(for: file)
                }
                .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            
            HStack() {
                
                VStack(alignment: .leading) {
                    // Image(getStatus(for: file) ? "files.selected" : "files.unselected")
                    Image("files.unselected")
                    
                        .frame(width: 25, height: 25)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                    Spacer()
                    
                }.onTapGesture {
                    // updateSelection(for: file)
                }
                Spacer()
            }
        }
    }
}

//#Preview {
//    AssetGridView()
//}

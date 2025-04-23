//
//  AddFileGridItemView.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddFileGridItemView: View {
    
    var file: VaultFileDB
    
    @StateObject var viewModel: AddFilesViewModel

    var body: some View {
        gridItemView
            .overlay(deleteButton, alignment: .topTrailing)
    }
    
    var gridItemView : some View {
        ZStack {
            file.gridImage
            self.fileNameText
        }
    }
    
    var deleteButton : some View {
        Button {
            viewModel.deleteFile(fileId: file.id)
        } label: {
            Image("delete.cross.icon")
                .padding(.all, 10)
        }
    }
    
    @ViewBuilder
    var fileNameText: some View {
        
        if self.file.tellaFileType != .image || self.file.tellaFileType != .video {
            VStack {
                Spacer()
                CustomText(self.file.name,
                               style: .body3Style)
                    .lineLimit(1)
                Spacer()
                    .frame(height: 6)
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}


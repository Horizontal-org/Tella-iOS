//
//  FileDropdown.swift
//  Tella
//
//  Created by Gustavo on 30/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FileDropdown: View {
    @State private var showFiles = false
    @Binding var files: Set<VaultFileDB>
    
    var body: some View {
        VStack {
            Button(action: {
                showFiles.toggle()
            }) {
                dropdownHeader
            }
            
            if showFiles {
                FileItems(files: files)
            }
        }
    }
    
    var dropdownHeader: some View {
        HStack {
            Text("\(files.count) \(files.count == 1 ? LocalizableUwazi.uwaziEntitySelectFilesDropdownTitleSingle.localized : LocalizableUwazi.uwaziEntitySelectFilesDropdownTitle.localized)")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
            Spacer()
            Text(showFiles ? LocalizableUwazi.uwaziEntitySelectFilesDropdownHide.localized : LocalizableUwazi.uwaziEntitySelectFilesDropdownShow.localized)
                .font(.custom(Styles.Fonts.boldFontName, size: 14))
                .foregroundColor(Styles.Colors.yellow)
            Image(showFiles ? "uwazi.chevron-up" : "uwazi.chevron-down")
        }
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct FileItems: View {
    
    var files: Set<VaultFileDB>
    
    var body: some View {
        VStack {
            ForEach(files.sorted{$0.created < $1.created}, id: \.id) { file in
                VaultFileItemView(file: VaultFileItemViewModel(image: file.listImage,
                                                      name: file.name,
                                                      size: file.size.getFormattedFileSize()))
                .padding(.vertical, 8)
                .padding(.horizontal, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

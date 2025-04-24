//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FileInfoView: View {
    
    @ObservedObject var viewModel : FileListViewModel
    
    var file: VaultFileDB
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }

    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableVault.verifInfoAppBar.localized)
    }

    var contentView: some View {
        VStack(alignment: .leading, spacing: 12){
            FileInfoItem(title: LocalizableVault.verifInfoFileName.localized, content: file.name)
            
            if file.tellaFileType != .folder {
                FileInfoItem(title: LocalizableVault.verifInfoSize.localized, content: file.size.getFormattedFileSize())
                FileInfoItem(title: LocalizableVault.verifInfoFormat.localized, content: file.fileExtension)
            }
            
            FileInfoItem(title: LocalizableVault.verifInfoCreated.localized, content: "\(file.longFormattedCreationDate)")
            
            if (file.tellaFileType == .video) || (file.tellaFileType == .image)  {
                FileInfoItem(title: LocalizableVault.verifInfoResolution.localized, content: file.formattedResolution ?? "")
            }
            
            if file.tellaFileType == .video || file.tellaFileType == .audio {
                FileInfoItem(title: LocalizableVault.verifInfoLength.localized, content: file.formattedDuration ?? "")
            }
            
            FileInfoItem(title: LocalizableVault.verifInfoFilePath.localized, content: viewModel.filePath)
            Spacer()
        } .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}

struct FileInfoItem :  View {
    
    var title : String = ""
    var content : String = ""
    
    var body : some View {
        HStack(spacing: 16) {
            
            Text(title)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.regularFontName, size: 12))
                .frame(width: 80, height: 16, alignment: .leading)
            
            Text(content)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.regularFontName, size: 12))
                .frame(alignment: .leading)
            
            Spacer()
        }
    }
}

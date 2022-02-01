//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileInfoView: View {
    
    @ObservedObject var viewModel : FileListViewModel
    
    var file: VaultFile
    
    var body: some View {
        
        ZStack {
            Styles.Colors.backgroundMain
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 12){
                FileInfoItem(title: LocalizableHome.fileName.localized, content: file.fileName)
                
                if file.type != .folder {
                    FileInfoItem(title: LocalizableHome.size.localized, content: file.size.getFormattedFileSize())
                    FileInfoItem(title: LocalizableHome.format.localized, content: file.fileExtension)
                }
                
                FileInfoItem(title: LocalizableHome.created.localized, content: "\(file.longFormattedCreationDate)")
                
                if (file.type == .video) || (file.type == .image)  {
                    FileInfoItem(title: LocalizableHome.resolution.localized, content: file.formattedResolution ?? "")
                }
                
                if file.type == .video {
                    FileInfoItem(title: LocalizableHome.length.localized, content: file.formattedDuration ?? "")
                }
                
                FileInfoItem(title: LocalizableHome.filePath.localized, content: viewModel.filePath)
                Spacer()
            } .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
        .toolbar {
            LeadingTitleToolbar(title: LocalizableHome.fileInfo.localized)
        }
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

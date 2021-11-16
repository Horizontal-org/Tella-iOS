//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {
    
    @ObservedObject var appModel: MainAppModel
    @State var shouldShowMore : Bool = false
    
    var body: some View {
        if appModel.vaultManager.recentFiles.count > 0 {
            VStack(alignment: .leading, spacing: 15){
                Text(LocalizableHome.recentFiles.localized)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                recentFilesView
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
        }
    }
    
    var recentFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                if (!shouldShowMore && appModel.vaultManager.recentFiles.count > 3) {
                    ForEach(0..<3) { i in
                        NavigationLink(destination: FileDetailView(appModel: appModel,
                                                                   file: appModel.vaultManager.recentFiles[i])) {
                            RecentFileCell(recentFile: appModel.vaultManager.recentFiles[i])
                        }
                        Divider()
                    }
                    LoadMoreCell(fileNumber: appModel.vaultManager.recentFiles.count)
                        .navigateTo(destination: FileListView(appModel: appModel,
                                                              files: appModel.vaultManager.recentFiles,
                                                              rootFile: appModel.vaultManager.root,
                                                              title: "Recent files"))
                } else {
                    ForEach(appModel.vaultManager.recentFiles, id: \.self) { file in
                        NavigationLink(destination: FileDetailView(appModel: appModel,
                                                                   file: file)) {
                            RecentFileCell(recentFile: file)
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(height: 70)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFilesListView(appModel: MainAppModel())
    }
}

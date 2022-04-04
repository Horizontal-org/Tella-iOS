//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {
    
    @EnvironmentObject var appModel: MainAppModel

    @State private var moreRecentFilesLoaded = false
    private var number : Int {
        return moreRecentFilesLoaded ? appModel.vaultManager.recentFiles.count : 3
    }
    
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
            
            if (appModel.vaultManager.recentFiles.count > 3) {
                allFilesItems
            } else {
                firstFilesItems
            }
        }.frame(height: 75)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    
    var allFilesItems : some View {
        HStack(spacing: 7) {
            // The 3 first or all items
            ForEach(0..<number, id: \.self) { i in
                RecentFileCell(recentFile: appModel.vaultManager.recentFiles[i].file)
                    .navigateTo(destination: FileDetailView(appModel: appModel,
                                                            file: appModel.vaultManager.recentFiles[i].file,
                                                            rootFile: appModel.vaultManager.recentFiles[i].rootFile,
                                                            folderPathArray: appModel.vaultManager.recentFiles[i].folderPathArray))
            }
            // More button
            if !moreRecentFilesLoaded &&  appModel.vaultManager.recentFiles.count >  3 {
                Button {
                    moreRecentFilesLoaded = true
                } label: {
                    LoadMoreCell(fileNumber: appModel.vaultManager.recentFiles.count)
                }
            }
        }.padding(.trailing, 17)
    }
    
    var firstFilesItems : some View {
        HStack(spacing: 7) {
            
            ForEach(appModel.vaultManager.recentFiles, id: \.self) { recentFile in
                
                RecentFileCell(recentFile: recentFile.file)
                    .navigateTo(destination: FileDetailView(appModel: appModel,
                                                            file: recentFile.file,
                                                            rootFile: recentFile.rootFile, folderPathArray: recentFile.folderPathArray))
            }
        }.padding(.trailing, 17)
        
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFilesListView()
    }
}

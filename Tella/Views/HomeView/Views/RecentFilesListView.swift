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
            HStack(spacing: 7) {
                
                if (appModel.vaultManager.recentFiles.count > 3) { // More recent files are loaded
                    ForEach(0..<number, id: \.self) { i in
                        RecentFileCell(recentFile: appModel.vaultManager.recentFiles[i])
                            .navigateTo(destination: FileDetailView(appModel: appModel,
                                                                    file: appModel.vaultManager.recentFiles[i]))
                    }
                    
                    if !moreRecentFilesLoaded {
                        Button {
                            moreRecentFilesLoaded = true
                        } label: {
                            LoadMoreCell(fileNumber: appModel.vaultManager.recentFiles.count)
                        }
                    }
                } else { // More recent files are not loaded
                    ForEach(appModel.vaultManager.recentFiles, id: \.self) { file in
                        
                        RecentFileCell(recentFile: file)
                            .navigateTo(destination: FileDetailView(appModel: appModel,file: file))
                    }
                }
            }.padding(.trailing, 17)
        }.frame(height: 75)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFilesListView()
    }
}

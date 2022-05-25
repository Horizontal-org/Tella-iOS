//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @State private var moreRecentFilesLoaded = false
    
    var recentFiles : [RecentFile]
    
    private var number : Int {
        return moreRecentFilesLoaded ? recentFiles.count : 3
    }
    
    var body: some View {
        if recentFiles.count > 0 {
            VStack(alignment: .leading, spacing: 15){
                Text(Localizable.Home.recentFilesSubhead)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                recentFilesView
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
        }
    }
    
    var recentFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            if (recentFiles.count > 3) {
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
                RecentFileCell(recentFile: recentFiles[i].file)
                    .navigateTo(destination: FileDetailView(appModel: appModel,
                                                            file: recentFiles[i].file,
                                                            rootFile: recentFiles[i].rootFile,
                                                            folderPathArray: recentFiles[i].folderPathArray))
            }
            // More button
            if !moreRecentFilesLoaded && recentFiles.count >  3 {
                Button {
                    moreRecentFilesLoaded = true
                } label: {
                    LoadMoreCell(fileNumber: recentFiles.count - 3)
                }
            }
        }.padding(.trailing, 17)
    }
    
    var firstFilesItems : some View {
        HStack(spacing: 7) {
            
            ForEach(recentFiles, id: \.self) { recentFile in
                
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
        RecentFilesListView(recentFiles: [])
    }
}

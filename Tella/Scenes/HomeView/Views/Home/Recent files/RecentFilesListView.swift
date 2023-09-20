//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {
    //TODO: Dhekra
    @EnvironmentObject var appModel: MainAppModel
    @State private var moreRecentFilesLoaded = false
    var recentFiles : Binding<[VaultFileDB]>
    
    private var number : Int {
        return moreRecentFilesLoaded ? recentFiles.wrappedValue.count : 3
    }
    
    var body: some View {
        
        if recentFiles.wrappedValue.count > 0 {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizableHome.recentFilesSubhead.localized)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                
                recentFilesView
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
        }
    }
    
    var recentFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            if (recentFiles.wrappedValue.count > 3) {
                allFilesItems
            } else {
                firstFilesItems
            }
        }.frame(height: 75)
    }
    
    var allFilesItems : some View {
        HStack(spacing: 7) {
            // The 3 first or all items
            ForEach(0..<number, id: \.self) { i in
                RecentFileCell(recentFile: recentFiles[i].wrappedValue,
                               desination: FileDetailView()
                    .environmentObject(FileListViewModel(appModel: appModel, selectedFile: recentFiles[i].wrappedValue)))
            }
            // More button
            if !moreRecentFilesLoaded && recentFiles.wrappedValue.count >  3 {
                Button {
                    moreRecentFilesLoaded = true
                } label: {
                    LoadMoreCell(fileNumber: recentFiles.wrappedValue.count - 3)
                }
            }
        }.padding(.trailing, 17)
    }

    var firstFilesItems : some View {
        HStack(spacing: 7) {
            
            ForEach(recentFiles.wrappedValue, id: \.self) { recentFile in
                
                RecentFileCell(recentFile: recentFile,
                               desination: FileDetailView().environmentObject(FileListViewModel(appModel: appModel, selectedFile: recentFile)))
            }
        }.padding(.trailing, 17)
    }
}

//struct ReventFilesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentFilesListView(recentFiles: [])
//    }
//}

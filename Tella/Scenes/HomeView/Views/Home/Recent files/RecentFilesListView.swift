//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct RecentFilesListView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @State private var moreRecentFilesLoaded = false
    var recentFiles : Binding<[VaultFileDB]>
    
    private var number : Int {
        if moreRecentFilesLoaded {
            return recentFiles.wrappedValue.count
        } else {
            return recentFiles.wrappedValue.count <= 3 ? recentFiles.wrappedValue.count :  3
        }
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
            HStack(spacing: 7) {
                
                // The 3 first or all items
                ForEach(0..<number, id: \.self) { i in
                    RecentFileCell(recentFile: recentFiles[i].wrappedValue,
                                   desination: FileDetailsView(appModel: appModel,
                                                               currentFile: recentFiles[i].wrappedValue,
                                                               fileListViewModel: FileListViewModel(appModel: appModel,
                                                                                                    selectedFile: recentFiles[i].wrappedValue))
                    )
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
            
        }.frame(height: 75)
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFilesListView(recentFiles: .constant([VaultFileDB.stub()]))
            .background(Styles.Colors.backgroundMain)
            .environmentObject(MainAppModel.stub())
        
    }
}

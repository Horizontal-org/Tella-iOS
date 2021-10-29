//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {
    
    @ObservedObject var appModel: MainAppModel
    
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
                ForEach(appModel.vaultManager.recentFiles, id: \.self) { file in
                    NavigationLink(destination: FileDetailView(file: file)) {
                        RecentFileCell(recentFile: file)
                    }
                    Divider()
                    
                }.listRowBackground(Color.red)
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

//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileGroupsView: View {
    
    @EnvironmentObject var appModel: MainAppModel

    var shouldShowFilesTitle : Bool
    
    let columns = [GridItem(.flexible(),spacing: 16),
                   GridItem(.flexible(),spacing: 16)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16 ) {
                if shouldShowFilesTitle {
                    
                    Text(Localizable.Home.tellaFilesSubhead)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white)
                }
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(homeFileItems, id: \.self) { homeFileItem in
                        FileGroupView(groupName: homeFileItem.title,
                                      iconName: homeFileItem.imageName)
                            .navigateTo(destination: FileListView(appModel: appModel,
                                                                  rootFile: appModel.vaultManager.root,
                                                                  fileType: homeFileItem.fileType,
                                                                  title: homeFileItem.title ))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .background(Styles.Colors.backgroundMain)
    }
}

struct FileGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        FileGroupsView(shouldShowFilesTitle: true)
    }
}

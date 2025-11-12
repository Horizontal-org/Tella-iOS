//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct FileGroupsView: View {
    
    var mainAppModel: MainAppModel
    
    var shouldShowFilesTitle : Bool
    
    let columns = [GridItem(.flexible(),spacing: 16),
                   GridItem(.flexible(),spacing: 16)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16 ) {
                if shouldShowFilesTitle {
                    Text(LocalizableHome.tellaFilesSubhead.localized)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white)
                }
                
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(homeFileItems, id: \.self) { homeFileItem in
                        FileGroupView(groupName: homeFileItem.title,
                                      iconName: homeFileItem.imageName,
                                      destination: FileListView(mainAppModel: mainAppModel,
                                                                filterType: homeFileItem.filterType,
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
        FileGroupsView(mainAppModel: MainAppModel.stub(),
                       shouldShowFilesTitle: true)        
    }
}

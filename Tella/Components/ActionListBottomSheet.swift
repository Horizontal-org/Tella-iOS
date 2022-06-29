//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ActionListBottomSheet: View {
    
    let items: [ListActionSheetItem]
    var headerTitle : String
    var action: ((ListActionSheetItem) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Title
            Text(self.headerTitle)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
            
            // Items
            ForEach(items, id: \.content) { item in
                
                switch item.viewType {
                case .item:
                    if item.isActive {
                        ListActionSheetRow(item: item, action: {action(item)})
                    }
                case .divider:
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.white)
                        .padding(EdgeInsets(top: 7, leading: -10 , bottom: 7, trailing: -10))
                }
            }
        }.padding(EdgeInsets(top: 21, leading: 24, bottom: 32, trailing: 24))
    }
}


struct ListActionSheetRow: View {
    var item: ListActionSheetItem
    var action: (() -> Void)
    
    var body: some View {
        Button(action: {
            item.action()
            action()
        }, label: {
            HStack(spacing: 0){
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24, alignment: .center)
                Text(item.content)
                    .frame(alignment: .leading)
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }).frame(height: 50, alignment: .center)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct FileActionsBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ActionListBottomSheet(items: [ListActionSheetItem(imageName: "camera-icon",
                                                          content: "Take photo/video",
                                                          action: {}, type: FileActionType.save)],
                              headerTitle: "Test",
                              action: {_ in})
        .background(Styles.Colors.backgroundMain)
    }
}


enum ActionSheetItemType {
    case item
    case divider
}

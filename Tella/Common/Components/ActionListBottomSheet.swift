//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ActionListBottomSheet: View {
    
    let items: [ListActionSheetItem]
    var headerTitle : String
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text(self.headerTitle)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.boldFontName, size: 18))
            ForEach(items, id: \.content) { item in
                ListActionSheetRow(item: item, isPresented: $isPresented)
            }
        }.padding(.all, 25)
    }
}

struct ListActionSheetRow: View {
    var item: ListActionSheetItem
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            isPresented = false
            item.action()
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
                    .font(Font.system(size: 14))
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }).frame(height: 50, alignment: .center)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct ListActionSheetItem {
    let imageName: String
    let content: String
    let action: () -> ()
    var isActive : Bool = true
}

struct FileActionsBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ActionListBottomSheet(items: [ListActionSheetItem(imageName: "camera-icon",
                                                          content: "Take photo/video",
                                                          action: {})],
                              headerTitle: "Test",
                              isPresented: .constant(true))
    }
}

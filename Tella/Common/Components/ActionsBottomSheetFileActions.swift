//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ActionsBottomSheetFileActions: View {
    @State var isPresented = true
    
    let items = [
        ListActionSheetItem(imageName: "upload-icon", content: "Upload", action: {
        }),
        ListActionSheetItem(imageName: "share-icon", content: "Share", action: {}),
        ListActionSheetItem(imageName: "move-icon", content: "Move", action: {}),
        ListActionSheetItem(imageName: "edit-icon", content: "Rename", action: {}),
        ListActionSheetItem(imageName: "save-icon", content: "Save to device", action: {}),
        ListActionSheetItem(imageName: "info-icon", content: "File information", action: {}),
        ListActionSheetItem(imageName: "delete-icon", content: "Delete", action: {})
    ]
    
    var body: some View {
        VStack{
            DragView(modalHeight: CGFloat(items.count * 40 + 100), color: Styles.Colors.backgroundTab, isShown: $isPresented){
                ListActionSheet(items: items, headerTitle: "filname.jpg", isPresented: $isPresented)
            }
        }
    }
}

struct ListActionSheet: View {
    let items: [ListActionSheetItem]
    var headerTitle : String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text(self.headerTitle)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 20, trailing: 0))
                .foregroundColor(.white)
                .font(Font.system(size: 14))
            ForEach(items, id: \.content) { item in
                ListActionSheetRow(item: item, isPresented: $isPresented)
            }
        }.padding()
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
        }).frame(height: 40, alignment: .center)
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
        ActionsBottomSheetFileActions()
    }
}

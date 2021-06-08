//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ActionsBottomSheet: View {
    @State var isShown = true
    
    let items = [
        ListActionSheetItem(imageName: "upload-icon", content: "Upload", action: {
        }),
        ListActionSheetItem(imageName: "share-icon", content: "Share", action: {}),
        ListActionSheetItem(imageName: "move-icon", content: "Move", action: {}),
        ListActionSheetItem(imageName: "edit-icon", content: "Rename", action: {}),
        ListActionSheetItem(imageName: "save-icon", content: "Save to device", action: {}),
        ListActionSheetItem(imageName: "info-icon", content: "File information", action: {}),
        ListActionSheetItem(imageName: "info-icon", content: "Delete", action: {})
    ]
    
    var body: some View {
        VStack{
            DragView(modalHeight: 400, isShown: $isShown){
                ListActionSheet(items: items, headerTitle: "filname.jpg", isShown: $isShown)
            }
        }
        
    }
}

struct ListActionSheet: View {
    let items: [ListActionSheetItem]
    var headerTitle : String
    @Binding var isShown: Bool

    var body: some View {
        VStack(alignment: .leading){
            Text(self.headerTitle)
                .padding(.horizontal, 21)
                .foregroundColor(.white)
                .font(Font.system(size: 14))
            ForEach(items, id: \.imageName) { item in
                ListActionSheetRow(item: item, isShown: $isShown)
            }
        }.padding()
    }
}

struct ListActionSheetRow: View {
    var item: ListActionSheetItem
    @Binding var isShown: Bool
    
    var body: some View {
        Button(action: {
            isShown = false
            item.action()
        }, label: {
            HStack{
                Image(item.imageName)
                Text(item.content)
                    .padding(.horizontal, 10)
                    .foregroundColor(.white)
                    .font(Font.custom("open-sans.regular", size: 12))
                Spacer()
            }.background(Color("PrimaryColor"))
            .padding(.bottom, 15)
        })
    }
}

struct ListActionSheetItem : Identifiable {
    let id = UUID()
    let imageName: String
    let content: String
    let action: () -> ()
}

struct FileActionsBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ActionsBottomSheet()
    }
}

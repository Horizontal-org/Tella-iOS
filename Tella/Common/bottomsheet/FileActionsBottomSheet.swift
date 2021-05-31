//
//  FileActionsBottomSheet.swift
//  Tella
//
//  Created by Ahlem on 26/05/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileActionsBottomSheet: View {
    @State var isShown = true
    var body: some View {
        VStack{
            DragView(modalHeight: 400, isShown: $isShown){
                ListActionSheet(onUploadClicked: {}, onShareClicked: {}, onMoveClicked: {}, onRenameClicked: {}, onSaveClicked: {}, onFileInfoClicked: {}, onDeleteClicked: {},fileName :"Img12333.jpeg")
            }
        }
        
    }
}

struct ListActionSheet: View {
    let items = [
        Item(imageName: "upload-icon", content: "Upload"),
        Item(imageName: "share-icon", content: "Share"),
        Item(imageName: "move-icon", content: "Move"),
        Item(imageName: "edit-icon", content: "Rename"),
        Item(imageName: "save-icon", content: "Save to device"),
        Item(imageName: "info-icon", content: "File information"),
        Item(imageName: "info-icon", content: "Delete")
    ]
    var onUploadClicked : () -> ()
    var onShareClicked : () -> ()
    var onMoveClicked : () -> ()
    var onRenameClicked : () -> ()
    var onSaveClicked : () -> ()
    var onFileInfoClicked : () -> ()
    var onDeleteClicked : () -> ()
    var fileName : String
    @State private var selection: Int? = nil

    var body: some View {
        VStack(alignment: .leading){
            Text(self.fileName)
                .padding(.horizontal, 21)
                .foregroundColor(.white)
                .font(Font.custom("open-sans.regular", size: 14))
            ActionRow(item: self.items[0])
            ActionRow(item: self.items[1])
            ActionRow(item: self.items[2])
            ActionRow(item: self.items[3])
            ActionRow(item: self.items[4])
            ActionRow(item: self.items[5])
            ActionRow(item: self.items[6])

           /* ScrollView {
                ForEach(self.items) { name in
                    ActionRow(item: name)
                }
            }.padding(.top, 21)
            .padding(.horizontal, 17)
*/
        }.padding()
        
    }
}

struct ActionRow: View {
    var item : Item
    var body: some View {
        HStack{
            Image(item.imageName)
            Text(item.content)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
                .font(Font.custom("open-sans.regular", size: 12))
            Spacer()
        }.background(Color("PrimaryColor"))
        .padding(.bottom, 15)
    }
}

struct Item : Identifiable {
    let id = UUID()
    let imageName : String
    let content : String
}

struct FileActionsBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        FileActionsBottomSheet()
    }
}

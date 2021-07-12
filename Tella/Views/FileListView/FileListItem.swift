//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListItem: View {

    var file: VaultFile
    var parentFile: VaultFile?

    @State var showingActionSheet: Bool = false
    @ObservedObject var appModel: MainAppModel
    @State var showFileInfoActive = false

    var body: some View {
        HStack(spacing: 0){
            RoundedRectangle(cornerRadius: 5)
                .fill(Styles.Colors.fileIconBackground)
                .frame(width: 35, height: 35, alignment: .center)
                .overlay(
                    file.gridImage
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                )
            VStack(alignment: .leading, spacing: 0){
                Text(file.fileName)
                    .font(Font(UIFont.boldSystemFont(ofSize: 14)))
                    .foregroundColor(Color.white)
                if #available(iOS 14.0, *) {
                    Text(file.created, style: .date)
                        .font(Font(UIFont.systemFont(ofSize: 10)))
                        .foregroundColor(Color(white: 0.8))
                } else {
                    TextDate(date: file.created)
                    // Fallback on earlier versions
                }
                NavigationLink(destination:
                   FileInfoView(file: file),
                   isActive: $showFileInfoActive) {
                     EmptyView()
                }.hidden()
            }
            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0))
            Spacer()
            HStack{
                Image("files.more")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .frame(width: 40, height: 40)
            .onTapGesture {
                showingActionSheet = true
            }
            FileActionMenu(selectedFile: file,
                           parentFile: parentFile,
                           showingActionSheet: $showingActionSheet,
                           showFileInfoActive: $showFileInfoActive, appModel: appModel
                )
        }
        .listRowBackground(Styles.Colors.backgroundMain)
        .background(Styles.Colors.backgroundMain)
        .frame(height: 45)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

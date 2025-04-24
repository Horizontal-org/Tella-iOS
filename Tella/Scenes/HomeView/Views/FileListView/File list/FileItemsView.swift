//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FileItemsView: View {
    
    @ObservedObject var fileListViewModel : FileListViewModel
    var files : [VaultFileDB]

    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2.5), count: 4)
    }
    
    private var height: CGFloat {
        let totalSpacing = (16 * 2) + (2.5 * 3) // Padding and spacing between cells
        return (UIScreen.screenWidth - totalSpacing) / 4
    }

    
    var body: some View {
        if fileListViewModel.viewType == .list {
            itemsListView
        } else {
            itemsGridView
        }
    }
    
    @available(iOS 14.0, *)
    var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 6) {
                ForEach(files, id: \.self) { file in
                    FileGridItem(file: file, fileListViewModel: fileListViewModel)
                        .frame(height: height)
                }
                Spacer().frame(height: 70)
            }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(files, id: \.self) { file in
                    FileListItem(file: file, fileListViewModel: fileListViewModel)
                        .frame(height: 60)
                }
                Spacer().frame(height: 70)
            }
        }
    }
}

struct FileItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FileItemsView(fileListViewModel: FileListViewModel.stub(), files: [VaultFileDB.stub(),
                              VaultFileDB.stub()])
            .background(Styles.Colors.backgroundMain)
    }
}

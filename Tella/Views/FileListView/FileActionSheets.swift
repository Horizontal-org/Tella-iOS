//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileSortMenu: View {
    
    @Binding var showingSortFilesActionSheet: Bool
    @Binding var sortBy: FileSortOptions

    var body: some View {
        HStack{
        }
        .actionSheet(isPresented: $showingSortFilesActionSheet, content: {
            menuActionSheet
        })
    }
    
    var menuActionSheet: ActionSheet {
        ActionSheet(title: Text("Sort by"),  buttons: [
            .default(Text("Name A > Z")) {
                sortBy = .nameAZ
            },
            .default(Text("Name Z > A")) {
                sortBy = .nameZA
            },
            .default(Text("Newest to oldest")) {
                sortBy = .newestToOldest
            },
            .default(Text("Oldest to newest")) {
                sortBy = .oldestToNewest
            },
            .cancel()
        ])
    }
    
}

struct FileActionMenu: View {
    
    var selectedFile: VaultFile
    var parentFile: VaultFile?
    @Binding var showingActionSheet: Bool
    @Binding var showFileInfoActive: Bool
    @ObservedObject var appModel: MainAppModel
    

    var body: some View {
        HStack{
        }
        .actionSheet(isPresented: $showingActionSheet, content: {
            menuActionSheet
        })
    }
    
    var menuActionSheet: ActionSheet {
        ActionSheet(title: Text("\(selectedFile.fileName)"),  buttons: [
//            .default(Text("Upload")) {
//            },
//            .default(Text("Share")) {
//            },
//            .default(Text("Move")) {
//            },
//            .default(Text("Rename")) {
//            },
//            .default(Text("Save to device")) {
//            },
            .default(Text("File information")) {
                showFileInfoActive = true
            },
            .destructive(Text("Delete")) {
                appModel.delete(file: selectedFile, from: parentFile)
            },
            .cancel()
        ])
    }
    
}

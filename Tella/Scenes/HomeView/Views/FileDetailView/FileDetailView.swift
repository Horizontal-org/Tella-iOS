//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
//    @ObservedObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var appModel: MainAppModel

    var body: some View {
        ZStack {
            detailsView()
            
            FileActionMenu()
            toolbar()
        }
         .environmentObject(fileListViewModel)
//        .navigationBarHidden(fileListViewModel.shouldHideNavigationBar)
    }
    
    @ViewBuilder
    func detailsView() -> some View {
        if let file = self.fileListViewModel.selectedFiles.first {
            switch file.tellaFileType {
            case .audio:
                AudioPlayerView(vaultFile: file)
            case .document:
                if let file = appModel.loadVaultFileToURL(file: file) {
                    QuickLookView(file: file)
                }
            case .video:
                VideoViewer(appModel: appModel, currentFile: file, playList: self.fileListViewModel.getVideoFiles())
            case .image:
                ImageViewer(imageData: appModel.loadFileData(fileName: file.id))
            case .folder:
                EmptyView()
                
            default:
                WebViewer(url: file.id)
            }
        }
    }
    
    func fileActionTrailingView() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            MoreFileActionButton(file: self.fileListViewModel.selectedFiles.first, moreButtonType: .navigationBar)
        }
    }
    
    @ViewBuilder
    func toolbar() -> some View {
        if let file = self.fileListViewModel.selectedFiles.first {
            
            ZStack{}
                .if(file.tellaFileType != .video, transform: { view in
                    view.toolbar {
                        LeadingTitleToolbar(title: file.name)
                        fileActionTrailingView()
                    }
                })
        }
    }
}

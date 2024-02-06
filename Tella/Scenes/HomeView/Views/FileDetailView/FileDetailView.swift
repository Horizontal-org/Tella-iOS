//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var appModel: MainAppModel

    var body: some View {
        ZStack {
            detailsView()
            FileActionMenu()
            toolbar()
        }
         .environmentObject(fileListViewModel)
         .onAppear(perform: {
             self.fileListViewModel.fileActionSource = .details
         })
    }
    
    @ViewBuilder
    func detailsView() -> some View {
        if let file = self.fileListViewModel.selectedFiles.first {
            switch file.tellaFileType {
            case .audio:
                AudioPlayerView(vaultFile: file)
            case .video:
                VideoViewer(appModel: appModel, currentFile: file, playList: self.fileListViewModel.getVideoFiles())
            case .image:
                ImageViewer(imageData: appModel.vaultManager.loadFileData1(file: file))
            case .folder:
                EmptyView()
                
            default:
                if let file = appModel.vaultManager.loadVaultFileToURL(file: file) {
                    QuickLookView(file: file)
                }
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

//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @ObservedObject var appModel: MainAppModel
    @StateObject var fileListViewModel: FileListViewModel
    
    var file: VaultFile?
    var videoFilesArray: [VaultFile]?
    var folderPathArray: [VaultFile]?
    
    init(appModel:MainAppModel,file: VaultFile?, videoFilesArray: [VaultFile]? = nil, rootFile:VaultFile?, folderPathArray: [VaultFile]?) {
        _fileListViewModel = StateObject(wrappedValue: FileListViewModel(appModel: appModel, fileType: nil, rootFile: rootFile, folderPathArray: folderPathArray ?? [],fileActionSource: .details))
        self.file = file
        self.videoFilesArray = videoFilesArray
        self.appModel = appModel
    }
    
    var body: some View {
        ZStack {
            detailsView()
            FileActionMenu()
            toolbar()
        }
        .environmentObject(fileListViewModel)
        .navigationBarHidden(fileListViewModel.shouldHideNavigationBar)
    }
    
    @ViewBuilder
    func detailsView() -> some View {
        if let file = self.file {
            switch file.type {
            case .audio:
                AudioPlayerView(vaultFile: file)
            case .document:
                if let file = appModel.vaultManager.loadVideo(file: file) {
                    QuickLookView(file: file)
                }
            case .video:
                VideoViewer(appModel: appModel, currentFile: file, playList: videoFilesArray ?? [file])
            case .image:
                ImageViewer(imageData: appModel.vaultManager.load(file: file))
            case .folder:
                EmptyView()
                
            default:
                WebViewer(url: file.containerName)
            }
        }
    }
    
    func fileActionTrailingView() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            MoreFileActionButton(file: file, moreButtonType: .navigationBar)
        }
    }
    
    @ViewBuilder
    func toolbar() -> some View {
        if let file = self.file {
            
            ZStack{}
                .if(file.type != .video, transform: { view in
                    view.toolbar {
                        LeadingTitleToolbar(title: file.fileName)
                        fileActionTrailingView()
                    }
                })
        }
    }
}

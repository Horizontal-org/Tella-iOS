//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailView: View {
    
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var appModel: MainAppModel
    
    @StateObject var viewModel : FileDetailsViewModel
    
    init(  appModel: MainAppModel, currentFile: VaultFileDB?) {
        _viewModel = StateObject(wrappedValue: FileDetailsViewModel(appModel: appModel, currentFile: currentFile))
    }
    
    var body: some View {
        ZStack {
            detailsView()
            FileActionMenu()
            toolbar()
            if !viewModel.documentIsReady && viewModel.currentFile?.tellaFileType != .video {
                ProgressView()
            }
            
        }
        .environmentObject(fileListViewModel)
        .onAppear(perform: {
            self.fileListViewModel.fileActionSource = .details
        })
    }
    
    @ViewBuilder
    func detailsView() -> some View {
        
        if viewModel.currentFile?.tellaFileType == .video {
            VideoViewer(appModel: appModel, currentFile: viewModel.currentFile, playList: self.fileListViewModel.getVideoFiles())
        } else {
            if viewModel.documentIsReady {
                switch viewModel.currentFile?.tellaFileType {
                case .audio:
                    AudioPlayerView(currentData: viewModel.data)
                case .image:
                    ImageViewer(imageData: viewModel.data)
                case .folder:
                    EmptyView()
                default:
                    if let urlDocument = viewModel.urlDocument {
                        QuickLookView(file: urlDocument)
                    }
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

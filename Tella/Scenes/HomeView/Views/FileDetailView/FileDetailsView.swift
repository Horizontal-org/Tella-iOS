//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailsView: View {
    
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var appModel: MainAppModel
    
    @StateObject var viewModel : FileDetailsViewModel
    @State private var isEditFilePresented = false
    
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
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.Colors.backgroundMain)
        .environmentObject(fileListViewModel)
        .onAppear(perform: {
            self.fileListViewModel.fileActionSource = .details
        })
    }
    
    @ViewBuilder
    func redirectEditFile() -> some View {
        switch viewModel.currentFile?.tellaFileType {
        case .image:
            EditImageView(viewModel: EditImageViewModel(fileListViewModel: fileListViewModel))
        case .audio:
            EditAudioView(editAudioViewModel: EditAudioViewModel(fileListViewModel: fileListViewModel))

        default:  EmptyView()
        }

    }
    
    @ViewBuilder
    func detailsView() -> some View {
        
        if viewModel.currentFile?.tellaFileType == .video {
            VideoViewer(appModel: appModel, currentFile: viewModel.currentFile, playList: self.fileListViewModel.getVideoFiles())
        } else {
            if viewModel.documentIsReady {
                switch viewModel.currentFile?.tellaFileType {
                case .audio:
                    let viewModel = AudioPlayerViewModel(currentData: viewModel.data)
                    AudioPlayerView(viewModel: viewModel, isViewDisappeared: $isEditFilePresented)
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
            HStack {
                editView()
                MoreFileActionButton(file: self.fileListViewModel.selectedFiles.first, moreButtonType: .navigationBar)
            }
        }
    }
    
    @ViewBuilder
    func editView() -> some View {
        if viewModel.shouldAddEditView {
            Button {
                //open edit view
                isEditFilePresented = true
                self.present(style: .fullScreen) {
                    self.redirectEditFile()
                }
            } label: {
                Image("file.edit")
            }
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

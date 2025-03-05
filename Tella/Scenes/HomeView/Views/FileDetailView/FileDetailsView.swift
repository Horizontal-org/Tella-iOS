//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import QuickLook

struct FileDetailsView: View {
    
    @ObservedObject var fileListViewModel: FileListViewModel
    
    @StateObject var viewModel : FileDetailsViewModel
    @State private var isEditFilePresented = false
    
    init(  appModel: MainAppModel, currentFile: VaultFileDB?, fileListViewModel: FileListViewModel) {
        _viewModel = StateObject(wrappedValue: FileDetailsViewModel(appModel: appModel, currentFile: currentFile))
        self.fileListViewModel = fileListViewModel
    }
    
    var body: some View {
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                detailsView()
            }
            
            FileActionMenu(fileListViewModel: fileListViewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.Colors.backgroundMain)
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: {
            self.fileListViewModel.fileActionSource = .details
        })
    }
    
    private func editFileAction() {
        switch fileListViewModel.currentSelectedVaultFile?.tellaFileType {
        case .image:
            showEditImageView()
        case .audio:
            showEditAudioView()
        default:  break
        }
    }
    
    private func showEditImageView() {
        self.present(style: .fullScreen) {
            EditImageView(viewModel: EditImageViewModel(fileListViewModel: fileListViewModel))
        }
    }
    
    private func showEditAudioView() {
        let viewModel = EditAudioViewModel(file: fileListViewModel.currentSelectedVaultFile,
                                           rootFile: fileListViewModel.rootFile,
                                           appModel: fileListViewModel.appModel,
                                           shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles)
        DispatchQueue.main.async {
            if fileListViewModel.currentSelectedVaultFile?.mediaCanBeEdited == true {
                self.present(style: .fullScreen) {
                    EditAudioView(viewModel: viewModel)
                }
            }else {
                Toast.displayToast(message: LocalizableVault.editAudioToastMsg.localized)
            }
        }
    }
    
    @ViewBuilder
    func detailsView() -> some View {
        
        if viewModel.currentFile?.tellaFileType == .video {
            VideoViewer(appModel: fileListViewModel.appModel,
                        currentFile: viewModel.currentFile,
                        playList: self.fileListViewModel.getVideoFiles(),
                        rootFile: fileListViewModel.rootFile,
                        fileListViewModel: fileListViewModel)
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
            } else {
                progressView
            }
        }
    }
    
    func showEditView() {
        isEditFilePresented = true
        self.editFileAction()
    }
    
    var moreFileActionButton : AnyView {
        AnyView(MoreFileActionButton(fileListViewModel: fileListViewModel,
                                     file: self.fileListViewModel.selectedFiles.first,
                                     moreButtonType: .navigationBar))
    }
    
    @ViewBuilder
    var navigationBarView : some View {
        if let file = self.fileListViewModel.selectedFiles.first {
            
            ZStack{}
                .if(file.tellaFileType != .video, transform: { view in
                    VStack {
                        NavigationHeaderView(title: file.name,
                                             middleButtonType: fileListViewModel.shouldAddEditView ? .editFile : .none,
                                             middleButtonAction: {showEditView()},
                                             rightButtonType: .custom,
                                             rightButtonView:moreFileActionButton )
                        view
                    }
                })
        }
    }
    
    var progressView: some View  {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Spacer()
        }
    }
}

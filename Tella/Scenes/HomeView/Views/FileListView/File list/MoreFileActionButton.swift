//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

enum MoreButtonType {
    case grid
    case list
    case navigationBar
}

struct MoreFileActionButton: View {
    
    @StateObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var appModel: MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var fileNameToUpdate : String = ""
    
    var file: VaultFileDB? = nil
    var moreButtonType : MoreButtonType
    @State var fileData: Data?
    private var modalHeight : CGFloat {
        return CGFloat((fileListViewModel.fileActionItems.count * 50) + 90)
    }
    var body: some View {
        ZStack{
            switch moreButtonType {
            case .grid:
                gridMoreButton.eraseToAnyView()
            case .list, .navigationBar:
                listMoreButton.eraseToAnyView()
            }
            
        }
    }
    
    var listMoreButton: some View {
        Button {
            showFileActionSheet()
        } label: {
            Image("files.more")
                .padding(.all, moreButtonType == .navigationBar ? 20 : 13)
        } .background(Color.gray)
    }
    
    var gridMoreButton: some View {
        Button {
            showFileActionSheet()
            
        } label: {
            Image("files.more")
                .frame(width: 35, height: 35)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: -6, trailing: -12))
        }.frame(width: 35, height: 35)
            .background(Color.gray)
    }
    
    private func showFileActionSheet() {
        if let file = file {
            fileListViewModel.updateSingleSelection(for: file)
        }
        
        sheetManager.showBottomSheet( modalHeight: modalHeight, content: {
            ActionListBottomSheet(items: fileListViewModel.fileActionItems,
                                  headerTitle: fileListViewModel.fileActionsTitle , action: {item in
                self.handleActions(item : item)
            })
        })
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? FileActionType else { return }
        
        switch type {
            
        case .share:
            hideMenu()
            showActivityViewController()
        case .move:
            self.hideMenu()
            fileListViewModel.showingMoveFileView = true
            fileListViewModel.oldParentFile = fileListViewModel.rootFile
            
        case .rename:
            if fileListViewModel.selectedFiles.count == 1 {
                fileNameToUpdate = fileListViewModel.selectedFiles[0].name
                showRenameFileSheet()
            }
            
        case .save:
            showSaveConfirmationSheet()
            
        case .info:
            fileListViewModel.showFileInfoActive = true
            self.hideMenu()
            
        case .delete:
            if fileListViewModel.filesAreUsedInConnections() {
                showDeleteWarningSheet()
            } else {
                showDeleteConfirmationSheet()
            }
        case .edit:
            hideMenu()
            editFileAction()
            
        default:
            break
        }
    }
    private func editFileAction() {
        switch fileListViewModel.currentSelectedVaultFile?.tellaFileType {
        case .image:
            showEditImageView()
        case .audio:
            showEditAudioView()
        case .video:
            showEditVideoView()
        default:  break
        }
    }
    private func showEditVideoView() {
        let viewModel = EditVideoViewModel(file: fileListViewModel.currentSelectedVaultFile,
                                           rootFile: fileListViewModel.rootFile,
                                           appModel: fileListViewModel.appModel,
                                           shouldReloadVaultFiles: $fileListViewModel.shouldReloadVaultFiles)
        DispatchQueue.main.async {
            if fileListViewModel.currentSelectedVaultFile?.mediaCanBeEdited == true {
                self.present(style: .fullScreen) {
                    EditVideoView(viewModel: viewModel)
                }
            }else {
                Toast.displayToast(message: LocalizableVault.editVideoToastMsg.localized)
            }
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
    
    private func hideMenu() {
        fileListViewModel.selectingFiles = false
        sheetManager.hide()
    }
    
    func showRenameFileSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            TextFieldBottomSheetView(titleText: LocalizableVault.renameFileSheetTitle.localized,
                                     validateButtonText: LocalizableVault.renameFileSaveSheetAction.localized,
                                     cancelButtonText:LocalizableVault.renameFileCancelSheetAction.localized,
                                     fieldContent: $fileNameToUpdate,
                                     fileName: fileListViewModel.selectedFiles.count == 1 ? fileListViewModel.selectedFiles[0].name : "",
                                     didConfirmAction: {
                fileListViewModel.selectedFiles[0].name = fileNameToUpdate
                fileListViewModel.renameSelectedFile()
            })
        })
    }
    
    func showDeleteConfirmationSheet() {
        let deleteConfirmation = fileListViewModel.deleteConfirmation
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            ConfirmBottomSheet(titleText: deleteConfirmation.title,
                               msgText: deleteConfirmation.message,
                               cancelText: LocalizableVault.deleteFileCancelSheetAction.localized,
                               actionText: LocalizableVault.deleteFileDeleteSheetAction.localized,
                               destructive: true,
                               didConfirmAction:{
                deleteAction()
                if fileListViewModel.fileActionSource == .details {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
        })
    }
    
    private func deleteAction() {
        fileListViewModel.deleteSelectedFiles()
        fileListViewModel.selectingFiles = false
        fileListViewModel.resetSelectedItems()
    }
    
    func showDeleteWarningSheet() {
        sheetManager.showBottomSheet(modalHeight: 194, content: {
            ConfirmBottomSheet(titleText: LocalizableVault.deleteFileWarningTitle.localized,
                               msgText:  LocalizableVault.deleteFileWarningDescription.localized,
                               cancelText: LocalizableVault.deleteFileCancelSheetAction.localized,
                               actionText: LocalizableVault.deleteFileDeleteAnyway.localized,
                               destructive: true,
                               didConfirmAction:{
                deleteAction()
            })
        })
    }
    
    
    func showSaveConfirmationSheet() {
        sheetManager.showBottomSheet( modalHeight: 180, content: {
            ConfirmBottomSheet(titleText: LocalizableVault.saveToDeviceSheetTitle.localized,
                               msgText: LocalizableVault.saveToDeviceSheetExpl.localized,
                               cancelText: LocalizableVault.saveToDeviceCancelSheetAction.localized,
                               actionText: LocalizableVault.saveToDeviceSaveSheetAction.localized.uppercased(),
                               didConfirmAction: {
                showDocumentPickerView()
            })
        })
    }
    
    func showDocumentPickerView() {
        self.present(style: .pageSheet) {
            DocumentPickerView(documentPickerType: .forExport,
                               URLs: appModel.vaultManager.loadVaultFilesToURL(files: fileListViewModel.selectedFiles)) { _ in
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
    func showActivityViewController() {
        self.present(style: .pageSheet) {
            ActivityViewController(fileData: fileListViewModel.getDataToShare())
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct MoreFileActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MoreFileActionButton( fileListViewModel: FileListViewModel.stub(),
                              moreButtonType: .navigationBar)
        .background(Color.red)
    }
}

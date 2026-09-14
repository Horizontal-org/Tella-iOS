//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

enum MoreButtonType {
    case grid
    case list
    case navigationBar
}

struct MoreFileActionButton: View {

    @ObservedObject var fileListViewModel: FileListViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var fileNameToUpdate : String = ""

    var file: VaultFileDB? = nil
    var moreButtonType : MoreButtonType
    @State var fileData: Data?

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
        }
    }

    var gridMoreButton: some View {
        Button {
            showFileActionSheet()

        } label: {
            Image("files.more")
                .frame(width: 35, height: 35)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: -6, trailing: -12))
        }.frame(width: 35, height: 35)

    }

    private func showFileActionSheet() {
        if let file = file {
            fileListViewModel.updateSingleSelection(for: file)
        }

        let content = ActionListBottomSheet(items: fileListViewModel.fileActionItems,
                                            headerTitle: fileListViewModel.fileActionsTitle , action: {item in
            self.dismiss {
                self.handleActions(item : item)

            }
        })
        showBottomSheetView(content: content)

    }

    private func handleActions(item: ListActionSheetItem) {

        guard let type = item.type as? FileActionType else { return }

        switch type {

        case .share:
            deselectFiles()
            showActivityViewController()
        case .move:
            self.deselectFiles()
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
            self.showFileInfoView()
            self.deselectFiles()

        case .delete:
            showDeleteConfirmationSheet()

        case .edit:
            deselectFiles()
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
                                           mainAppModel: fileListViewModel.mainAppModel,
                                           editMedia: EditVideoParameters())
        DispatchQueue.main.async {
            self.present(style: .fullScreen) {
                EditVideoView(viewModel: viewModel)
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
                                           mainAppModel: fileListViewModel.mainAppModel,
                                           editMedia: EditAudioParameters())
        DispatchQueue.main.async {
            self.present(style: .fullScreen) {
                EditAudioView(viewModel: viewModel)
            }
        }
    }

    private func deselectFiles() {
        fileListViewModel.selectingFiles = false
    }

    func showRenameFileSheet() {

        let content = TextFieldBottomSheetView(titleText: LocalizableVault.renameFileSheetTitle.localized,
                                               validateButtonText: LocalizableVault.renameFileSaveSheetAction.localized,
                                               cancelButtonText:LocalizableVault.renameFileCancelSheetAction.localized,
                                               fieldContent: $fileNameToUpdate,
                                               fileName: fileListViewModel.selectedFiles.count == 1 ? fileListViewModel.selectedFiles[0].name : "",
                                               shouldHideSheet: false,

                                               didConfirmAction: {

            fileListViewModel.selectedFiles[0].name = fileNameToUpdate
            fileListViewModel.renameSelectedFile()
            self.dismiss()

        },didCancelAction:  {
            self.dismiss()
        })

        showBottomSheetView(content: content)

    }

    func showFileInfoView() {
        guard let file else { return }
        let destination = FileInfoView(viewModel: self.fileListViewModel, file: file)
        self.navigateTo(destination: destination)
    }

    func showDeleteConfirmationSheet() {
        let deleteConfirmation = fileListViewModel.deleteConfirmation

        let content = ConfirmBottomSheet(titleText: deleteConfirmation.title,
                                         msgText: deleteConfirmation.message,
                                         cancelText: LocalizableVault.deleteFileCancelSheetAction.localized,
                                         actionText: LocalizableVault.deleteFileDeleteSheetAction.localized,
                                         destructive: true,
                                         shouldHideSheet: false,
                                         didConfirmAction:{

            if fileListViewModel.filesAreUsedInConnections() {
                self.dismiss {
                    showDeleteWarningSheet()
                }
            } else {
                self.dismiss {
                    deleteAction()
                    if fileListViewModel.fileActionSource == .details {
                        self.presentationMode.wrappedValue.dismiss()
                    }

                }
            }

        },didCancelAction:  {
            self.dismiss()
        })

        showBottomSheetView(content: content)

    }

    private func deleteAction() {
        fileListViewModel.deleteSelectedFiles()
        fileListViewModel.selectingFiles = false
        fileListViewModel.resetSelectedItems()
    }

    func showDeleteWarningSheet() {

        let content = ConfirmBottomSheet(titleText: LocalizableVault.deleteFileWarningTitle.localized,
                                         msgText:  LocalizableVault.deleteFileWarningDescription.localized,
                                         cancelText: LocalizableVault.deleteFileCancelSheetAction.localized,
                                         actionText: LocalizableVault.deleteFileDeleteAnyway.localized,
                                         destructive: true,
                                         shouldHideSheet: false,
                                         didConfirmAction:{
            self.dismiss {
                deleteAction()
                if fileListViewModel.fileActionSource == .details {
                    self.presentationMode.wrappedValue.dismiss()
                }

            }
        },didCancelAction:  {
            self.dismiss()
        })

        showBottomSheetView(content: content)

    }

    func showSaveConfirmationSheet() {

        let content = ConfirmBottomSheet(titleText: LocalizableVault.saveToDeviceSheetTitle.localized,
                                         msgText: LocalizableVault.saveToDeviceSheetExpl.localized,
                                         cancelText: LocalizableVault.saveToDeviceCancelSheetAction.localized,
                                         actionText: LocalizableVault.saveToDeviceSaveSheetAction.localized.uppercased(),
                                         shouldHideSheet: false,
                                         didConfirmAction: {
            self.dismiss{
                showDocumentPickerView()
            }
        },didCancelAction:  {
            self.dismiss()
        })

        showBottomSheetView(content: content)

    }

    func showDocumentPickerView() {
        let items = fileListViewModel.getDataToShare()
        let tempURLs = items.compactMap { $0 as? URL }
        self.present(style: .pageSheet) {
            DocumentPickerView(documentPickerType: .forExport,
                               URLs: tempURLs) { _ in
            }.edgesIgnoringSafeArea(.all)
        }
    }

    func showActivityViewController() {
        let items = fileListViewModel.getDataToShare()
        self.present(style: .pageSheet) {
            ActivityViewController(fileData: items, onDismiss: {})
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

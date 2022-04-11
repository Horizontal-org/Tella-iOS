//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileActionMenu: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isPresented = true
    @State var showingDocumentPicker = false
    @State var showingDeleteConfirmationSheet = false
    @State var showingSaveConfirmationSheet = false
    @State var showingRenameFileConfirmationSheet = false
    
    @State var fileName : String = ""
    
    var modalHeight : CGFloat {
        
        let dividerHeight = fileListViewModel.fileActionItems.filter{$0.viewType == ActionSheetItemType.divider}.count * 20
        return CGFloat((fileListViewModel.fileActionItems.count * 50) - dividerHeight  + 90)
    }
    
    var body: some View {
        
        fileActionMenuContentView
        fileDocumentExporter
        deleteFileView
        renameFileView
        if fileListViewModel.showingMoveFileView {
            moveFilesView
        }
        ShareFileView()
        showFileInfoLink
    }
    
    var fileActionMenuContentView : some View {
        ZStack{
            DragView(modalHeight: modalHeight,
                     isShown: $fileListViewModel.showingFileActionMenu) {
                ActionListBottomSheet(items: fileListViewModel.fileActionItems,
                                      headerTitle: fileListViewModel.fileActionsTitle,
                                      isPresented: $isPresented, action: {item in
                    
                    self.handleActions(item : item)
                })
            }
        }
    }
    
    var fileDocumentExporter: some View {
        ConfirmBottomSheet(titleText: "Save to device gallery?",
                           msgText: "This will make your files accessible from outside Tella, in your device’s gallery and by other apps.",
                           cancelText: "CANCEL",
                           actionText: "SAVE",
                           modalHeight: 180,
                           isPresented: $showingSaveConfirmationSheet,
                           didConfirmAction: {
            showingSaveConfirmationSheet = false
            showingDocumentPicker = true
        })
            .sheet(isPresented: $showingDocumentPicker, onDismiss: {
                appModel.vaultManager.clearTmpDirectory()
            }, content: {
                DocumentPickerView(documentPickerType: .forExport,
                                   URLs: appModel.vaultManager.load(files: fileListViewModel.selectedFiles)) { _ in
                }
            })
    }
    
    var deleteFileView: some View {
        ConfirmBottomSheet(titleText: "Delete file?",
                           msgText: "The selected files will be permanently delated from Tella.",
                           cancelText: "CANCEL",
                           actionText: "DELETE",
                           destructive: true,
                           modalHeight: 161,
                           isPresented: $showingDeleteConfirmationSheet,
                           didConfirmAction:{
            showingDeleteConfirmationSheet = false
            fileListViewModel.selectedFiles.forEach { vaultFile in
                appModel.delete(file: vaultFile, from: fileListViewModel.rootFile)
                if fileListViewModel.fileActionSource == .details {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        })
    }
    
    var renameFileView : some View {
        TextFieldBottomSheet(titleText: "Rename file",
                             validateButtonText: "SAVE",
                             isPresented: $showingRenameFileConfirmationSheet,
                             fieldContent: $fileName,
                             fileName: fileListViewModel.selectedFiles.count == 1 ? fileListViewModel.selectedFiles[0].fileName : "",
                             fieldType: FieldType.fileName,
                             didConfirmAction: {
            fileListViewModel.selectedFiles[0].fileName = fileName
            appModel.rename(file: fileListViewModel.selectedFiles[0], parent: fileListViewModel.rootFile)
        })
    }
    
    
    @ViewBuilder
    private var showFileInfoLink : some View{
        if let currentSelectedVaultFile = fileListViewModel.currentSelectedVaultFile {
            NavigationLink(destination:
                            FileInfoView(viewModel: self.fileListViewModel, file: currentSelectedVaultFile),
                           isActive: $fileListViewModel.showFileInfoActive) {
                EmptyView()
            }.frame(width: 0, height: 0)
                .hidden()
        }
    }
    
    
    var moveFilesView : some View {
        MoveFilesView(title: fileListViewModel.fileActionsTitle)
    }
    
    private func hideMenu() {
        fileListViewModel.selectingFiles = false
        fileListViewModel.showingFileActionMenu = false
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? FileActionType else { return }
        
        switch type {
            
        case .share:
            fileListViewModel.showingFileActionMenu = false
            fileListViewModel.showingShareFileView = true
            
        case .move:
            fileListViewModel.showingMoveFileView = true
            fileListViewModel.oldRootFile = fileListViewModel.rootFile
            self.hideMenu()
            
        case .rename:
            if fileListViewModel.selectedFiles.count == 1 {
                fileName = fileListViewModel.selectedFiles[0].fileName
                showingRenameFileConfirmationSheet = true
                self.hideMenu()
            }
            
        case .save:
            showingSaveConfirmationSheet = true
            self.hideMenu()
            
        case .info:
            fileListViewModel.showFileInfoActive = true
            self.hideMenu()
            
        case .delete:
            showingDeleteConfirmationSheet = true
            self.hideMenu()
            
        default:
            break
        }
    }
    
}

struct FileActionMenu_Previews: PreviewProvider {
    static var previews: some View {
        FileActionMenu()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}

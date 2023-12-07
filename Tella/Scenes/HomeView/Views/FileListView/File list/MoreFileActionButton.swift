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
    
    @EnvironmentObject var fileListViewModel: FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var appModel: MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var fileNameToUpdate : String = ""
    
    var file: VaultFileDB? = nil
    var moreButtonType : MoreButtonType
    
    private var modalHeight : CGFloat {
        let dividerHeight = fileListViewModel.fileActionItems.filter{$0.viewType == ActionSheetItemType.divider}.count * 20
        return CGFloat((fileListViewModel.fileActionItems.count * 50) - dividerHeight  + 90)
    }
    
    private var deleteTitle :String {
       return fileListViewModel.selectedFiles.count > 1 ? LocalizableVault.deleteFilesSheetTitle.localized : LocalizableVault.deleteFileSheetTitle.localized
    }
    
    private var deleteMessage :String {
       return fileListViewModel.selectedFiles.count > 1 ? LocalizableVault.deleteFilesSheetExpl.localized : LocalizableVault.deleteFileSheetExpl.localized
    }

    var body: some View {
        
        switch moreButtonType {
        case .grid:
            return gridMoreButton.eraseToAnyView()
        case .list, .navigationBar:
            return listMoreButton.eraseToAnyView()
        }
    }
    
    var listMoreButton: some View {
        Button {
            showFileActionSheet()
        } label: {
            Image("files.more")
                .frame(width: 40, height: 40)
        }.frame(width: 40, height: 40)
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
            fileListViewModel.showingShareFileView = true
            
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
            showDeleteConfirmationSheet()
            
        default:
            break
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
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            ConfirmBottomSheet(titleText: deleteTitle,
                               msgText: deleteMessage,
                               cancelText: LocalizableVault.deleteFileCancelSheetAction.localized,
                               actionText: LocalizableVault.deleteFileDeleteSheetAction.localized,
                               destructive: true,
                               didConfirmAction:{
                
                fileListViewModel.deleteSelectedFiles()
                fileListViewModel.selectingFiles = false
                fileListViewModel.resetSelectedItems()

                if fileListViewModel.fileActionSource == .details {
                    self.presentationMode.wrappedValue.dismiss()
                }
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
                fileListViewModel.showingDocumentPicker = true
            })
            
        })
    }
}

struct MoreFileActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MoreFileActionButton( moreButtonType: .navigationBar)
            .background(Color.red)
    }
}

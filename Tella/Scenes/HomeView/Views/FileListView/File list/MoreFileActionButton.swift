//
//  MoreFileActionButton.swift
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
    
    var file: VaultFile? = nil
    var moreButtonType : MoreButtonType
    
    var modalHeight : CGFloat {
        let dividerHeight = fileListViewModel.fileActionItems.filter{$0.viewType == ActionSheetItemType.divider}.count * 20
        return CGFloat((fileListViewModel.fileActionItems.count * 50) - dividerHeight  + 90)
    }
    
    var body: some View {
        
        switch moreButtonType {
        case .grid:
            return gridMoreButton.eraseToAnyView()
        case .list:
            return listMoreButton.eraseToAnyView()
        case .navigationBar:
            return navigationBarMoreButton.eraseToAnyView()
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
    
    var navigationBarMoreButton: some View {
        
        Button {
            showFileActionSheet()
        } label: {
            Image("files.more-top")
                .frame(width: 40, height: 40)
        }.frame(width: 40, height: 40)
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
            fileListViewModel.oldRootFile = fileListViewModel.rootFile
            
        case .rename:
            if fileListViewModel.selectedFiles.count == 1 {
                fileNameToUpdate = fileListViewModel.selectedFiles[0].fileName
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
            TextFieldBottomSheetView(titleText: Localizable.Vault.renameFileSheetTitle,
                                     validateButtonText: Localizable.Vault.renameFileSaveSheetAction,
                                     cancelButtonText:Localizable.Vault.renameFileCancelSheetAction,
                                     fieldContent: $fileNameToUpdate,
                                     fileName: fileListViewModel.selectedFiles.count == 1 ? fileListViewModel.selectedFiles[0].fileName : "",
                                     fieldType: FieldType.fileName,
                                     didConfirmAction: {
                fileListViewModel.selectedFiles[0].fileName = fileNameToUpdate
                appModel.rename(file: fileListViewModel.selectedFiles[0], parent: fileListViewModel.rootFile)
            })
            
        })
    }
    
    func showDeleteConfirmationSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, content: {
            ConfirmBottomSheet(titleText: Localizable.Vault.deleteFileSheetTitle,
                               msgText: Localizable.Vault.deleteFileSheetExpl,
                               cancelText: Localizable.Vault.deleteFileCancelSheetAction,
                               actionText: Localizable.Vault.deleteFileDeleteSheetAction,
                               destructive: true,
                               didConfirmAction:{
                appModel.delete(files: fileListViewModel.selectedFiles, from: fileListViewModel.rootFile)
                
                if fileListViewModel.fileActionSource == .details {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
        })
    }
    
    func showSaveConfirmationSheet() {
        sheetManager.showBottomSheet( modalHeight: 180, content: {
            ConfirmBottomSheet(titleText: Localizable.Vault.saveToDeviceSheetTitle,
                               msgText: Localizable.Vault.saveToDeviceSheetExpl,
                               cancelText: Localizable.Vault.saveToDeviceCancelSheetAction,
                               actionText: Localizable.Vault.saveToDeviceSaveSheetAction.uppercased(),
                               didConfirmAction: {
                fileListViewModel.showingDocumentPicker = true
            })
            
        })
    }
}

struct MoreFileActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MoreFileActionButton( moreButtonType: .list)
    }
}

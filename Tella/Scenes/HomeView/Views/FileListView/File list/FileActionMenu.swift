//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

//enum FileActionMenuType {
//    case single
//    case multiple
//}

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
    
    var shouldShowDivider : Bool {
        (firstItems.contains(where: {$0.isActive}))
    }
    
    var modalHeight : CGFloat {
        let itemsNumber = firstItems.filter{$0.isActive}.count + secondItems.filter{$0.isActive}.count
        return CGFloat((itemsNumber * 50) + 90)
    }
    
    var firstItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "share-icon",
                            content: "Share",
                            action: {
                                fileListViewModel.showingFileActionMenu = false
                                fileListViewModel.showingShareFileView = true
                            },isActive: fileListViewModel.shouldActivateShare)
    ]
        
    }
    var secondItems : [ListActionSheetItem] {
        
        return [
            
            ListActionSheetItem(imageName: "move-icon",
                                content: "Move to another folder",
                                action: {
                                    fileListViewModel.showingMoveFileView = true
                                    fileListViewModel.oldRootFile = fileListViewModel.rootFile
                                    
                                    self.hideMenu()
                                    
                                }),
            
            ListActionSheetItem(imageName: "edit-icon",
                                content: "Rename",
                                action: {
                                    if fileListViewModel.selectedFiles.count == 1 {
                                        fileName = fileListViewModel.selectedFiles[0].fileName
                                        showingRenameFileConfirmationSheet = true
                                        
                                        self.hideMenu()
                                        
                                        
                                    }
                                }, isActive: fileListViewModel.shouldActivateRename),
            
            ListActionSheetItem(imageName: "save-icon",
                                content: "Save to device",
                                action: {
                                    showingSaveConfirmationSheet = true
                                    
                                    self.hideMenu()
                                    
                                },isActive: fileListViewModel.shouldActivateShare),
            
            ListActionSheetItem(imageName: "info-icon",
                                content: "File information",
                                action: {
                                    fileListViewModel.showFileInfoActive = true
                                    
                                    self.hideMenu()
                                    
                                }, isActive: fileListViewModel.shouldActivateFileInformation),
            
            ListActionSheetItem(imageName: "delete-icon",
                                content: "Delete",
                                action: {
                                    showingDeleteConfirmationSheet = true
                                    
                                    self.hideMenu()
                                })
        ]
    }
    
    var body: some View {
        ZStack{
            DragView(modalHeight: modalHeight,
                     isShown: $fileListViewModel.showingFileActionMenu) {
                fileActionMenuContentView
            }
        }
        
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
        VStack(alignment: .leading, spacing: 0) {
            Text(fileListViewModel.fileActionsTitle)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .padding(EdgeInsets(top: 8, leading: 1 , bottom: 15, trailing: 0))
            
            ForEach(firstItems, id: \.content) { item in
                if item.isActive {
                    ListActionSheetRow(item: item, isPresented: $isPresented)
                }
            }
            
            if shouldShowDivider {
                Divider()
                    .frame(height: 0.5)
                    .background(Color.white)
                    .padding(EdgeInsets(top: 7, leading: -10 , bottom: 7, trailing: -10))
            }
            
            ForEach(secondItems, id: \.content) { item in
                if item.isActive {
                    ListActionSheetRow(item: item, isPresented: $isPresented)
                }
            }
        }.padding(EdgeInsets(top: 21, leading: 24, bottom: 32, trailing: 24))
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
}

struct FileActionMenu_Previews: PreviewProvider {
    static var previews: some View {
        FileActionMenu()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}

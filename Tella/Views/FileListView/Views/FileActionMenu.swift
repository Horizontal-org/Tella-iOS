//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

enum FileActionMenuType {
    case single
    case multiple
}

struct FileActionMenu: View {
    
    var selectedFiles: [VaultFile]
    var parentFile: VaultFile?
    var fileActionMenuType : FileActionMenuType
    
    @Binding var showingActionSheet: Bool
    @Binding var showFileInfoActive: Bool
    @ObservedObject var appModel: MainAppModel
    @State var isPresented = true
    @State var showingDocumentPicker = false
    @State var showingDeleteConfirmationSheet = false
    @State var showingSaveConfirmationSheet = false
    @State var showingRenameFileConfirmationSheet = false
    @State var showingShareFileSheet = false
    
    @State var fileName : String = ""
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var firstItems : [ListActionSheetItem] { return [
        //        ListActionSheetItem(imageName: "upload-icon",
        //                            content: "Upload",
        //                            action: {
        //                                self.presentationMode.wrappedValue.dismiss()
        //                            }),
        ListActionSheetItem(imageName: "share-icon",
                            content: "Share",
                            action: {
                                showingActionSheet = false
                                showingShareFileSheet = true
                            },isActive: shouldActivateShare)
    ]}
    
    var shouldActivateShare : Bool {
        (fileActionMenuType == .single && (selectedFiles.count == 1 && selectedFiles[0].type != .folder)) ||
        (fileActionMenuType == .multiple && !selectedFiles.contains{$0.type == .folder})
    }
    
    var shouldShowDivider : Bool {
        (firstItems.contains(where: {$0.isActive}))
    }
    
    var modalHeight : CGFloat {
        let itemsNumber = firstItems.filter{$0.isActive}.count + secondItems.filter{$0.isActive}.count
        return CGFloat((itemsNumber * 40) + 85)
    }
    
    var secondItems : [ListActionSheetItem] {
        
        return [
            
            ListActionSheetItem(imageName: "move-icon",
                                content: "Move to another folder",
                                action: {
                                }),
            
            ListActionSheetItem(imageName: "edit-icon",
                                content: "Rename",
                                action: {
                                    if selectedFiles.count == 1 {
                                        showingActionSheet = false
                                        fileName = selectedFiles[0].fileName
                                        showingRenameFileConfirmationSheet = true
                                    }
                                },
                                isActive: fileActionMenuType == .single ? true : false )  ,
            
            ListActionSheetItem(imageName: "save-icon",
                                content: "Save to device",
                                action: {
                                    showingActionSheet = false
                                    showingSaveConfirmationSheet = true
                                }),
            
            ListActionSheetItem(imageName: "info-icon",
                                content: "File information",
                                action: {
                                    showFileInfoActive = true
                                }),
            
            ListActionSheetItem(imageName: "delete-icon",
                                content: "Delete",
                                action: {
                                    showingActionSheet = false
                                    showingDeleteConfirmationSheet = true
                                })
        ]}
    
    var body: some View {
        ZStack{
            DragView(modalHeight: modalHeight,
                     color: Styles.Colors.backgroundTab,
                     isShown: $showingActionSheet) {
                FileActionMenuContentView
            }
        }
        
        fileDocumentExporter
        deleteFileView
        renameFileView
        shareFileView
    }
    
    var FileActionMenuContentView : some View {
        VStack(alignment: .leading, spacing: 0) {
            Text( (fileActionMenuType == .single && selectedFiles.count == 1) ?  selectedFiles[0].fileName : "\(selectedFiles.count) items")
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .padding(EdgeInsets(top: 8, leading: 8 , bottom: 15, trailing: 0))
            
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
                                   URLs: appModel.vaultManager.load(files: selectedFiles)) { _ in
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
            selectedFiles.forEach { vaultFile in
                appModel.delete(file: vaultFile, from: parentFile)
            }
        })
    }
    
    var renameFileView : some View {
        TextFieldBottomSheet(titleText: "Rename file",
                             validateButtonText: "SAVE",
                             isPresented: $showingRenameFileConfirmationSheet,
                             fieldContent: $fileName,
                             fileName: selectedFiles.count == 1 ? selectedFiles[0].fileName : "",
                             fieldType: FieldType.fileName,
                             didConfirmAction: {
            selectedFiles[0].fileName = fileName
            appModel.rename(file: selectedFiles[0], parent: parentFile)
        })
    }
    
    var shareFileView : some View {
        ZStack {}
        .sheet(isPresented: $showingShareFileSheet, onDismiss: {
            appModel.vaultManager.clearTmpDirectory()
        }, content: {
            ActivityViewController(fileData: appModel.getFilesForShare(files: selectedFiles))
        })
    }
}

struct FileActionMenu_Previews: PreviewProvider {
    static var previews: some View {
        FileActionMenu(selectedFiles: [VaultFile(type: FileType.folder, fileName: "test")],
                       parentFile: VaultFile(type: FileType.folder, fileName: "test"),
                       fileActionMenuType: FileActionMenuType.multiple,
                       showingActionSheet: .constant(true),
                       showFileInfoActive: .constant(true),
                       appModel: MainAppModel())
    }
}

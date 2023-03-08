//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFilesToDraftView: View {

    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var draftReportVM: DraftReportVM
    
    private let gridLayout: [GridItem] = [GridItem(spacing: 12),
                                          GridItem(spacing: 12),
                                          GridItem(spacing: 12)]
    
    private let gridItemHeight = (UIScreen.screenWidth - 64.0) / 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            attachFilesTextView
            
            itemsGridView
            
            addButtonView
        }
    }
    
    var attachFilesTextView: some View {
        Text("Attach files here")
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
    }
    
    var itemsGridView: some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 12) {
            ForEach(draftReportVM.files.sorted{$0.created < $1.created}, id: \.id) { file in
                ReportFileGridView(file: file)
                    .frame(height: (UIScreen.screenWidth - 64) / 3 )
            }
        }
    }
    
    var addButtonView: some View {
        Button {
            UIApplication.shared.endEditing()
            showAddFileSheet()
        } label: {
            Image("reports.add")
        }
    }
    
    var fileListView : some View {
        FileListView(appModel: appModel,
                     rootFile: appModel.vaultManager.root,
                     fileType: nil,
                     title: "Select files",
                     fileListType: .selectFiles,
                     resultFile: $draftReportVM.resultFile)
    }
    
    func showAddFileSheet() {
        
        sheetManager.showBottomSheet( modalHeight: CGFloat(draftReportVM.addFileToDraftItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: draftReportVM.addFileToDraftItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                self.handleActions(item : item)
            })
        })
    }
    
    func showAddPhotoVideoSheet() {
        sheetManager.showBottomSheet( modalHeight:  CGFloat(AddPhotoVideoItems.count * 40 + 100), content: {
            ActionListBottomSheet(items: AddPhotoVideoItems,
                                  headerTitle: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized, action: {item in
                self.handleAddPhotoVideoActions(item : item)
            })
        })
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? ManageFileType else { return }
        
        switch type {
            
        case .camera:
            sheetManager.hide()
            draftReportVM.showingCamera = true
            
        case .recorder:
            sheetManager.hide()
            draftReportVM.showingRecordView = true
            
        case .fromDevice:
            showAddPhotoVideoSheet()
            
        case .tellaFile:
            sheetManager.hide()
            draftReportVM.showingFileList = true
        default:
            break
        }
    }
    
    private func handleAddPhotoVideoActions(item: ListActionSheetItem) {
        guard let type = item.type as? AddPhotoVideoType else { return  }
        
        switch type {
        case .photoLibrary:
            draftReportVM.showingImagePicker = true
        default:
            draftReportVM.showingImportDocumentPicker = true
        }
    }
}

struct AddFilesToDraftView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}

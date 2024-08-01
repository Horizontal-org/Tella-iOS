//
//  AddFilesToDraftView.swift
//  Tella
//
//  Created by gus valbuena on 6/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddFilesToDraftView<T: ServerProtocol>: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var draftReportVM: DraftMainViewModel<T>
    
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
        Text(LocalizableReport.attachFiles.localized)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
    }
    
    var itemsGridView: some View {
        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 12) {
            ForEach(draftReportVM.files.sorted{$0.created < $1.created}, id: \.id) { file in
                ReportFileGridView<T>(file: file)
                    .frame(height: (UIScreen.screenWidth - 64) / 3 )
                    .environmentObject(draftReportVM)
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
                     filterType: .audioPhotoVideo,
                     title: LocalizableReport.selectFiles.localized,
                     fileListType: .selectFiles,
                     resultFile: $draftReportVM.resultFile)
    }

    func showAddFileSheet() {
        
        sheetManager.showBottomSheet( modalHeight: CGFloat(draftReportVM.addFileToDraftItems.count * 50 + 90), content: {
            ActionListBottomSheet(items: draftReportVM.addFileToDraftItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action: {item in
                self.handleActions(item : item)
            })
        })
    }
    
    func showAddPhotoVideoSheet() {
        draftReportVM.showingImagePicker = true
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
            navigateTo(destination: fileListView)
            
        default:
            break
        }
    }
}

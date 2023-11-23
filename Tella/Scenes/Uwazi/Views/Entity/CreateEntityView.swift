//
//  CreateEntityView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateEntityView: View {
    @StateObject var entityViewModel : UwaziEntityViewModel
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let modelHeight = 200.0
    
    init(appModel: MainAppModel, templateId: Int, serverId: Int) {
        _entityViewModel = StateObject(wrappedValue: UwaziEntityViewModel(mainAppModel: appModel, templateId:templateId, serverId: serverId))
    }
    var body: some View {
        ContainerView {
            contentView
            
            photoVideoPickerView
        }
        .navigationBarHidden(true)
        .overlay(cameraView)
        .overlay(recordView)
    }
    
    fileprivate var contentView: some View {
        VStack(alignment: .leading) {
            createEntityHeaderView
            draftContentView
            Spacer()
            UwaziDividerWidget()
            bottomActionView
        }
    }

    fileprivate var createEntityHeaderView: some View {
        CreateDraftHeaderView(title: entityViewModel.template!.entityRow?.name ?? "",
                              isDraft: true,
                              hideSaveButton: true,
                              closeAction: { showSaveEntityConfirmationView() },
                              saveAction: { })
    }


    
    fileprivate var draftContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(entityViewModel.entryPrompts, id: \.id) { prompt in
                        RenderPropertyComponentView(prompt: prompt)
                            .environmentObject(sheetManager)
                            .environmentObject(entityViewModel)
                    }
                }.padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    fileprivate var bottomActionView: some View {
        Button(action: {
            let checkMandatoryFields = self.entityViewModel.handleMandatoryProperties()
            
            if !checkMandatoryFields {
                navigateTo(destination: SubmitEntityView(entityViewModel: entityViewModel))
            }
        }) {
            Text(LocalizableUwazi.uwaziEntityActionNext.localized)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 32))
                .foregroundColor(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var cameraView : some View {
        entityViewModel.showingCamera ?
        CameraView(sourceView: SourceView.addReportFile,
                   showingCameraView: $entityViewModel.showingCamera,
                   resultFile: $entityViewModel.resultFile,
                   mainAppModel: entityViewModel.mainAppModel,
                   rootFile: entityViewModel.mainAppModel.vaultManager.root) : nil
    }
    
    var recordView : some View {
        entityViewModel.showingRecordView ?
        RecordView(appModel: entityViewModel.mainAppModel,
                   rootFile: entityViewModel.mainAppModel.vaultManager.root,
                    sourceView: .addReportFile,
                    showingRecoredrView: $entityViewModel.showingRecordView,
                    resultFile: $entityViewModel.resultFile) : nil
        }
    
    var photoVideoPickerView : some View {
        PhotoVideoPickerView(showingImagePicker: $entityViewModel.showingImagePicker,
                             showingImportDocumentPicker: $entityViewModel.showingImportDocumentPicker,
                             appModel: entityViewModel.mainAppModel,
                             resultFile: $entityViewModel.resultFile,
                             rootFile:  $entityViewModel.mainAppModel.vaultManager.root)
    }

    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: modelHeight) {
            ConfirmBottomSheet(titleText: LocalizableUwazi.uwaziEntityExitSheetTitle.localized,
                               msgText: LocalizableUwazi.uwaziEntityExitSheetExpl.localized,
                               cancelText: LocalizableReport.exitCancel.localized.uppercased(),
                               actionText: LocalizableSettings.UwaziLanguageCancel.localized.uppercased(),
                               didConfirmAction: {
                
            }, didCancelAction: {
                dismissViews()
            })
        }
    }
    
    private func dismissViews() {
        sheetManager.hide()
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

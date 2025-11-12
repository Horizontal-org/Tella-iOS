//
//  CreateEntityView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CreateEntityView: View {
    @StateObject var entityViewModel : UwaziEntityViewModel
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let modelHeight = 200.0
    
    init(mainAppModel: MainAppModel, templateId: Int? = nil, entityInstanceID:Int? = nil) {
        _entityViewModel = StateObject(wrappedValue: UwaziEntityViewModel(mainAppModel: mainAppModel, templateId:templateId, entityInstanceId: entityInstanceID))
    }
    
    var body: some View {
        
        ZStack {
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            photoVideoPickerView
        }
        .overlay(cameraView)
        .overlay(recordView)
        .onReceive(entityViewModel.$shouldHideView, perform: { shouldHideView in
            if shouldHideView {
                dismissViews()
            }
        })
    }
    
    fileprivate var contentView: some View {
        VStack(alignment: .leading) {
            draftContentView
            Spacer()
            UwaziDividerWidget()
            bottomActionView
        }
    }
    
    fileprivate var navigationBarView: some View {
        NavigationHeaderView(title: entityViewModel.templateName,
                             backButtonAction: { showSaveEntityConfirmationView() },
                             rightButtonType: .save,
                             rightButtonAction: {entityViewModel.saveEntityDraft() })
    }
    
    fileprivate var draftContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(entityViewModel.entryPrompts, id: \.id) { prompt in
                        RenderPropertyComponentView(prompt: prompt, entityViewModel: entityViewModel)
                            .environmentObject(sheetManager)
                    }
                }.padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    fileprivate var bottomActionView: some View {
        Button(action: {
            let checkMandatoryFields = self.entityViewModel.handleMandatoryProperties()
            
            if !checkMandatoryFields {
                entityViewModel.saveAnswersToEntityInstance()
                navigateTo(destination: SummaryEntityView(mainAppModel: entityViewModel.mainAppModel,
                                                          entityInstance: entityViewModel.entityInstance))
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
                   mainAppModel: entityViewModel.mainAppModel) : nil
    }
    
    var recordView : some View {
        entityViewModel.showingRecordView ?
        RecordView(mainAppModel: entityViewModel.mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $entityViewModel.showingRecordView,
                   resultFile: $entityViewModel.resultFile) : nil
    }
    
    var photoVideoPickerView : some View {
        PhotoVideoPickerView(showingImagePicker: $entityViewModel.showingImagePicker,
                             showingImportDocumentPicker: $entityViewModel.showingImportDocumentPicker,
                             mainAppModel: entityViewModel.mainAppModel,
                             resultFile: $entityViewModel.resultFile)
    }
    
    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet() {
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
        self.popTo(ViewClassType.uwaziView)
    }
}


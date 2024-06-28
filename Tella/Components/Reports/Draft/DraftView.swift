//
//  DraftView.swift
//  Tella
//
//  Created by gus valbuena on 6/26/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DraftView<VM: DraftViewModelProtocol>: View  {
    @StateObject var viewModel: VM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var mainAppModel: MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var reportsViewModel : BaseReportsViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        // TO DO: INCLUDE SERVER SELECTION VIEW!!!!!!
        ContainerView {
            contentView
                .environmentObject(viewModel)
            photoVideoPickerView
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.successSavingReportPublisher)  { successSavingReport in
            if successSavingReport {
                handleSuccessSavingReport()
            }
        }
        .onReceive(viewModel.failureSavingReportPublisher)  { failureSavingReport in
            if failureSavingReport {
                handleReportFailure()
            }
        }
        .overlay(recordView)
        .overlay(cameraView)
    }
    
    var draftHeaderView: some View {
        NavigationHeaderView(
            backButtonAction: {
                UIApplication.shared.endEditing()
                showSaveReportConfirmationView()
            },
            rightButtonAction: { viewModel.saveDraftReport() },
            type: .draft,
            isRightButtonEnabled: viewModel.reportIsDraft
        )
    }

    
    var contentView: some View {
        VStack(alignment: .leading) {
            draftHeaderView
            draftContentView
            bottomDraftView
        }
    }
    
    var draftContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    TextfieldView(fieldContent: $viewModel.title,
                                  isValid: $viewModel.isValidTitle,
                                  shouldShowError: $viewModel.shouldShowError,
                                  fieldType: .text,
                                  placeholder: LocalizableReport.reportsListTitle.localized,
                                  shouldShowTitle: true)
                    
                    Spacer()
                        .frame(height: 34)
                    
                    UnderlinedTextEditorView(placeholder:  LocalizableReport.reportsListDescription.localized,
                                             fieldContent: $viewModel.description,
                                             isValid: $viewModel.isValidDescription,
                                             shouldShowError: $viewModel.shouldShowError,
                                             shouldShowTitle: true)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    AddFilesToDraftView<VM>()
                        .environmentObject(viewModel)
                    
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    var bottomDraftView: some View {
        HStack {
            submitLaterButton
            submitButton
        }.padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
    }
    
    var submitLaterButton: some View {
        Button {
            viewModel.saveFinalizedReport()
        } label: {
            Image("reports.submit-later")
                .opacity(viewModel.reportIsValid ? 1 : 0.4)
        }.disabled(!viewModel.reportIsValid)
    }
    
    var submitButton: some View {
        TellaButtonView<AnyView>(
            title: LocalizableReport.reportsSubmit.localized,
            nextButtonAction: .action,
            buttonType: .yellow,
            isValid: .constant(true)
        ) {
            viewModel.submitReport()
        }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
    
    var outboxDetailsView: some View {
        OutboxDetailsView(appModel: mainAppModel,
                          reportsViewModel: reportsViewModel,
                          reportId: viewModel.reportId,
                          shouldStartUpload: true)
        .environmentObject(reportsViewModel)
    }
    
    var photoVideoPickerView: some View {
        PhotoVideoPickerView(showingImagePicker: $viewModel.showingImagePicker,
                             showingImportDocumentPicker: $viewModel.showingImportDocumentPicker,
                             appModel: mainAppModel,
                             resultFile: $viewModel.resultFile,
                             shouldReloadVaultFiles: .constant(false))
    }
        
    var recordView: some View {
        viewModel.showingRecordView ?
        RecordView(appModel: mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $viewModel.showingRecordView,
                   resultFile: $viewModel.resultFile) : nil
    }
        
    var cameraView: some View {
        viewModel.showingCamera ?
        CameraView(sourceView: SourceView.addReportFile,
                   showingCameraView: $viewModel.showingCamera,
                   resultFile: $viewModel.resultFile,
                   mainAppModel: mainAppModel) : nil
    }
    
    private func showSaveReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: LocalizableReport.exitTitle.localized,
                                msgText: LocalizableReport.exitMessage.localized,
                                cancelText: LocalizableReport.exitCancel.localized.uppercased(),
                                actionText:LocalizableReport.exitSave.localized.uppercased(), didConfirmAction: {
                viewModel.saveDraftReport()
            }, didCancelAction: {
                dismissViews()
            })
        }
    }
    
    private func handleSuccessSavingReport() {
        switch viewModel.status {
        case .draft:
            handleSuccessSavingDraft()
        case .finalized:
            handleSuccessSavingOutbox()
        case .submissionScheduled:
            handleSuccessSavingReportForSubmission()
        default:
            break
        }
    }
    
    private func handleReportFailure() {
        dismissViews()
        Toast.displayToast(message: LocalizableCommon.commonError.localized)
    }
    
    private func handleSuccessSavingDraft() {
        reportsViewModel.selectedCell = .draft
        dismissViews()
        Toast.displayToast(message: LocalizableReport.draftSavedToast.localized)
    }
        
    private func handleSuccessSavingOutbox() {
        reportsViewModel.selectedCell = .outbox
        dismissViews()
        Toast.displayToast(message: LocalizableReport.outboxSavedToast.localized)
    }
        
    private func handleSuccessSavingReportForSubmission() {
        DispatchQueue.main.async {
            navigateTo(destination: outboxDetailsView)
        }
    }
    
    private func dismissViews() {
        sheetManager.hide()
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

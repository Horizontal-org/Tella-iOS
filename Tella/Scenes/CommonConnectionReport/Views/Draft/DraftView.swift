//
//  DraftView.swift
//  Tella
//
//  Created by gus valbuena on 6/26/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DraftView: View  {
    @StateObject var viewModel: DraftMainViewModel
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var sheetManager: SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var showOutboxDetailsViewAction: (() -> Void)
    
    var body: some View {
        
        ZStack {
            
            ContainerViewWithHeader {
                headerView
            } content: {
                contentView
            }
            
            serverListMenuView
            photoVideoPickerView
        }

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
    
    var headerView: some View {
        NavigationHeaderView(title: LocalizableReport.reportsText.localized,
                             backButtonAction: {backAction()},
                             trailingButtonAction: { viewModel.saveDraftReport() },
                             trailingButton: .save,
                             isTrailingButtonEnabled: viewModel.reportIsDraft)
    }
    
    
    var contentView: some View {
        VStack(alignment: .leading) {
            draftContentView
            bottomDraftView
        }
    }
    
    var draftContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    if viewModel.hasMoreServer  {
                        Text(LocalizableReport.reportsSendTo.localized)
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .foregroundColor(Color.white)
                        
                        Button {
                            DispatchQueue.main.async {
                                self.menuFrame = geometry.frame(in: CoordinateSpace.global)
                                shouldShowMenu = true
                            }
                            
                        } label: {
                            HStack {
                                Text(viewModel.serverName)
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .foregroundColor(Color.white.opacity(0.87))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image("reports.arrow-down")
                                    .padding()
                                
                            }
                        }.background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                        
                        Spacer()
                            .frame(height: 55)
                        
                    } else {
                        Spacer()
                            .frame(height: 5)
                    }
                    TextfieldView(fieldContent: $viewModel.title,
                                  isValid: $viewModel.isValidTitle,
                                  shouldShowError: $viewModel.shouldShowError,
                                  validationErrorMessage: LocalizableSettings.settCreateFolderError.localized,
                                  fieldType: .folderName,
                                  placeholder: LocalizableReport.reportsListTitle.localized,
                                  shouldShowTitle: true,
                                  shouldValidateOnChange:true)
                    .frame(height: 98)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    UnderlinedTextEditorView(placeholder:  LocalizableReport.reportsListDescription.localized,
                                             fieldContent: $viewModel.description,
                                             isValid: $viewModel.isValidDescription,
                                             shouldShowError: $viewModel.shouldShowError,
                                             shouldShowTitle: true)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    AddFilesToDraftView(draftReportVM: viewModel)
                    
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    @ViewBuilder
    var serverListMenuView: some View {
        
        if shouldShowMenu {
            VStack {
                Spacer()
                    .frame(height: menuFrame.origin.y +  10)
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(viewModel.serverArray, id: \.self) { server in
                            
                            Button {
                                shouldShowMenu = false
                                viewModel.server = server
                                
                            } label: {
                                Text(server.name ?? "")
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.all, 14)
                            }.background(server.id == viewModel.server?.id ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
                        }
                    }.frame(minHeight: 40, maxHeight: 250)
                        .background(Styles.Colors.backgroundMain)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
            
            .background(Color.clear)
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
            isValid: $viewModel.reportIsValid
        ) {
            viewModel.submitReport()
        }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
    
    var photoVideoPickerView: some View {
        PhotoVideoPickerView(showingImagePicker: $viewModel.showingImagePicker,
                             showingImportDocumentPicker: $viewModel.showingImportDocumentPicker,
                             appModel: viewModel.mainAppModel,
                             resultFile: $viewModel.resultFile,
                             shouldReloadVaultFiles: .constant(false))
    }
    
    var recordView: some View {
        viewModel.showingRecordView ?
        RecordView(appModel: viewModel.mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $viewModel.showingRecordView,
                   resultFile: $viewModel.resultFile) : nil
    }
    
    var cameraView: some View {
        viewModel.showingCamera ?
        CameraView(sourceView: SourceView.addReportFile,
                   showingCameraView: $viewModel.showingCamera,
                   resultFile: $viewModel.resultFile,
                   mainAppModel: viewModel.mainAppModel) : nil
    }
    
    private func backAction() {
        UIApplication.shared.endEditing()
        showSaveReportConfirmationView()
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
            showOutboxDetailsViewAction()
        default:
            break
        }
    }
    
    private func handleReportFailure() {
        dismissViews()
        Toast.displayToast(message: LocalizableCommon.commonError.localized)
    }
    
    private func handleSuccessSavingDraft() {
        viewModel.reportsMainViewModel.selectedPage = .draft
        dismissViews()
        Toast.displayToast(message: LocalizableReport.draftSavedToast.localized)
    }
    
    private func handleSuccessSavingOutbox() {
        viewModel.reportsMainViewModel.selectedPage = .outbox
        dismissViews()
        Toast.displayToast(message: LocalizableReport.outboxSavedToast.localized)
    }
    
    
    private func dismissViews() {
        sheetManager.hide()
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

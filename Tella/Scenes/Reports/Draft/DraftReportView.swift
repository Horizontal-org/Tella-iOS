//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DraftReportView: View {
    
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(mainAppModel: MainAppModel, reportId:Int? = nil) {
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(mainAppModel: mainAppModel,reportId:reportId))
    }
    
    var body: some View {
        
        ContainerView {
            
            contentView
                .environmentObject(reportViewModel)
            
            serverListMenuView
            
            photoVideoPickerView
            
        }
        .navigationBarHidden(true)
        .onTapGesture {
            shouldShowMenu = false
        }
        .onReceive(reportViewModel.$successSavingReport)  { successSavingReport in
            if successSavingReport {
                handleSuccessSavingReport()
            }
        }
        .onReceive(reportViewModel.$failureSavingReport)  { failureSavingReport in
            if failureSavingReport {
                handleReportFailure()
            }
        }
        
        .overlay(recordView)
        
        .overlay(cameraView)
    }
    
    var contentView: some View {
        
        VStack(alignment: .leading) {
            
            draftReportHeaderView
            
            draftContentView
            
            bottomDraftView
        }
    }
    
    var draftReportHeaderView: some View {
        
        HStack(spacing: 0) {
            
            Button {
                UIApplication.shared.endEditing()
                showSaveReportConfirmationView()
            } label: {
                Image("close")
                    .padding(EdgeInsets(top: 10, leading: 12, bottom: 5, trailing: 16))
            }
            
            Text(LocalizableReport.reportsText.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            
            Spacer()
            
            
            Button {
                reportViewModel.saveDraftReport()
            } label: {
                Image("reports.save")
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .opacity(reportViewModel.reportIsDraft ? 1 : 0.4)
            }.disabled(!reportViewModel.reportIsDraft)
            
            
        }.frame(height: 56)
    }
    
    var draftContentView: some View {
        
        GeometryReader { geometry in
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    if reportViewModel.hasMoreServer  {
                        
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
                                Text(reportViewModel.serverName)
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
                    
                    TextfieldView(fieldContent: $reportViewModel.title,
                                  isValid: $reportViewModel.isValidTitle,
                                  shouldShowError: $reportViewModel.shouldShowError,
                                  fieldType: .text,
                                  placeholder : LocalizableReport.reportsListTitle.localized,
                                  shouldShowTitle: true)
                    
                    Spacer()
                        .frame(height: 34)
                    
                    UnderlinedTextEditorView(placeholder:  LocalizableReport.reportsListDescription.localized,
                                   fieldContent: $reportViewModel.description,
                                   isValid: $reportViewModel.isValidDescription,
                                   shouldShowError: $reportViewModel.shouldShowError,
                                   shouldShowTitle: true)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    AddFilesToDraftView<DraftReportVM>()
                        .environmentObject(reportViewModel)
                    
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
                        
                        ForEach(reportViewModel.serverArray, id: \.self) { server in
                            
                            Button {
                                shouldShowMenu = false
                                reportViewModel.server = server
                                
                            } label: {
                                Text(server.name ?? "")
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.all, 14)
                            }.background(server.id == reportViewModel.server?.id ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
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
            
            // Submit later button
            Button {
                reportViewModel.saveFinalizedReport()
            } label: {
                Image("reports.submit-later")
                    .opacity(reportViewModel.reportIsValid ? 1 : 0.4)
            }.disabled(!reportViewModel.reportIsValid)
            
            // Submit button
            TellaButtonView<AnyView> (title: reportViewModel.isNewDraft ? LocalizableReport.reportsSubmit.localized : LocalizableReport.reportsSend.localized,
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: $reportViewModel.reportIsValid) {
                submitReport()
            } .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
    }
    
    var outboxDetailsView: some View {
        OutboxDetailsView(appModel: mainAppModel,
                          reportsViewModel: reportsViewModel,
                          reportId: reportViewModel.reportId,
                          shouldStartUpload: true)
        .environmentObject(reportsViewModel)
    }
    
    var cameraView : some View {
        reportViewModel.showingCamera ?
        CameraView(sourceView: SourceView.addReportFile,
                   showingCameraView: $reportViewModel.showingCamera,
                   resultFile: $reportViewModel.resultFile,
                   mainAppModel: mainAppModel) : nil
    }
    
    var recordView : some View {
        reportViewModel.showingRecordView ?
        RecordView(appModel: mainAppModel,
                   sourceView: .addReportFile,
                   showingRecoredrView: $reportViewModel.showingRecordView,
                   resultFile: $reportViewModel.resultFile) : nil
    }
    
    var photoVideoPickerView : some View {
        PhotoVideoPickerView(showingImagePicker: $reportViewModel.showingImagePicker,
                             showingImportDocumentPicker: $reportViewModel.showingImportDocumentPicker,
                             appModel: mainAppModel,
                             resultFile: $reportViewModel.resultFile,
                             shouldReloadVaultFiles: .constant(false))
    }
    
    
    private func submitReport() {

        reportViewModel.saveReportForSubmission()
        
    }
    
    private func showSaveReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: LocalizableReport.exitTitle.localized,
                               msgText: LocalizableReport.exitMessage.localized,
                               cancelText: LocalizableReport.exitCancel.localized.uppercased(),
                               actionText:LocalizableReport.exitSave.localized.uppercased(), didConfirmAction: {
                reportViewModel.saveDraftReport()
            }, didCancelAction: {
                dismissViews()
            })
        }
    }
    
    private func handleSuccessSavingReport() {
        switch reportViewModel.status {
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

struct DraftReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        DraftReportView(mainAppModel: MainAppModel.stub())
            .environmentObject(ReportsViewModel(mainAppModel: MainAppModel.stub()))
    }
}


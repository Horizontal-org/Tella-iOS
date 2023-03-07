//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DraftReportView: View {
    
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    @State var shouldShowOutboxReport : Bool = false
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(mainAppModel: MainAppModel, reportId:Int? = nil) {
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(mainAppModel: mainAppModel,reportId:reportId))
    }
    
    var body: some View {
        
        NavigationContainerView {
            
            contentView
                .environmentObject(reportViewModel)
            
            serverListMenuView
            
            photoVideoPickerView
            
            fileListViewLink
            
            ReportDetailsViewLink
            
        } .onAppear(perform: {
            reportViewModel.fillReportVM()
        })
        .onTapGesture {
            shouldShowMenu = false
        }
        
        .overlay(recordView)
        
        .overlay(cameraView)
    }
    
    var contentView: some View {
        
        VStack(alignment: .leading) {
            
            draftReportHeaderView
            
            draftContentView
                .overlay(successView)
            
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
                    .padding(EdgeInsets(top: 16, leading: 12, bottom: 5, trailing: 16))
            }
            
            Text("Report")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            
            Spacer()
            
            
            Button {
                saveDraftReport()
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
                        
                        Text("Send report to:")
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
                            .frame(height: 10)
                    }
                    
                    TextfieldView(fieldContent: $reportViewModel.title,
                                  isValid: $reportViewModel.isValidTitle,
                                  shouldShowError: $reportViewModel.shouldShowError,
                                  fieldType: .text,
                                  placeholder : "Title",
                                  shouldShowTitle: reportViewModel.hasMoreServer)
                    .frame(height: 30)
                    
                    Spacer()
                        .frame(height: 34)
                    
                    TextEditorView(placeholder: "Description",
                                   fieldContent: $reportViewModel.description,
                                   isValid: $reportViewModel.isValidDescription,
                                   shouldShowError: $reportViewModel.shouldShowError,
                                   shouldShowTitle: reportViewModel.hasMoreServer)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    AddFilesToDraftView()
                    
                    Spacer()
                    
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    @ViewBuilder
    var successView: some View {
        if reportViewModel.showingSuccessMessage {
            SaveSuccessView(text: "The audio recording was saved to your Tella files.",
                            isPresented: $reportViewModel.showingSuccessMessage)
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
                submitReportLater()
            } label: {
                Image("reports.submit-later")
                    .opacity(reportViewModel.reportIsValid ? 1 : 0.4)
            }.disabled(!reportViewModel.reportIsValid)
            
            // Submit button
            TellaButtonView<AnyView> (title: reportViewModel.isNewDraft ? "SUBMIT" : "SEND",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: $reportViewModel.reportIsValid) {
                submitReport()
            } .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
    }
    
    @ViewBuilder
    private var fileListViewLink: some View {
        if reportViewModel.showingFileList {
            fileListView
                .addNavigationLink(isActive: $reportViewModel.showingFileList, shouldAddEmptyView: true)
        }
    }
    
    private var ReportDetailsViewLink: some View {
        OutboxDetailsView(appModel: mainAppModel,
                          reportsViewModel: reportsViewModel,
                          reportId: reportViewModel.reportId,
                          shouldStartUpload: true)
        .environmentObject(reportsViewModel)
        .addNavigationLink(isActive: $shouldShowOutboxReport)
        
    }
    
    var fileListView : some View {
        FileListView(appModel: mainAppModel,
                     rootFile: mainAppModel.vaultManager.root,
                     fileType: nil,
                     title: "Select files",
                     fileListType: .selectFiles,
                     resultFile: $reportViewModel.resultFile)
    }
    
    var cameraView : some View {
        reportViewModel.showingCamera ?
        CameraView(sourceView: SourceView.addSingleFile,
                   showingCameraView: $reportViewModel.showingCamera,
                   resultFile: $reportViewModel.resultFile,
                   mainAppModel: mainAppModel,
                   rootFile: mainAppModel.vaultManager.root) : nil
    }
    
    var recordView : some View {
        reportViewModel.showingRecordView ?
        RecordView(appModel: mainAppModel,
                   rootFile: mainAppModel.vaultManager.root,
                   sourceView: .addSingleFile,
                   showingRecoredrView: $reportViewModel.showingRecordView,
                   resultFile: $reportViewModel.resultFile) : nil
    }
    
    var photoVideoPickerView : some View {
        PhotoVideoPickerView(showingImagePicker: $reportViewModel.showingImagePicker,
                             showingImportDocumentPicker: $reportViewModel.showingImportDocumentPicker,
                             appModel: mainAppModel,
                             resultFile: $reportViewModel.resultFile)
    }
    
    
    private func submitReport() {
        reportViewModel.status = .finalized
        reportViewModel.saveReport()
        
        DispatchQueue.main.async {
            shouldShowOutboxReport = true
        }
    }
    
    private func submitReportLater() {
        reportViewModel.status = .finalized
        reportViewModel.saveReport()
        reportsViewModel.selectedCell = .outbox
        dismissViews()
    }
    
    private func saveDraftReport() {
        reportViewModel.status = .draft
        reportViewModel.saveReport()
        reportsViewModel.selectedCell = .draft
        dismissViews()
    }
    
    private func showSaveReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Exit report?",
                               msgText: "Your draft will be lost.",
                               cancelText: "Exit anyway".uppercased(),
                               actionText: "save and exit".uppercased(), didConfirmAction: {
                saveDraftReport()
            }, didCancelAction: {
                dismissViews()
            })
        }
    }
    
    private func dismissViews() {
        sheetManager.hide()
        reportsViewModel.newReportRootLinkIsActive = false
        reportsViewModel.editRootLinkIsActive = false
    }
}

struct DraftReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        DraftReportView(mainAppModel: MainAppModel())
            .environmentObject(ReportsViewModel(mainAppModel: MainAppModel()))
    }
}

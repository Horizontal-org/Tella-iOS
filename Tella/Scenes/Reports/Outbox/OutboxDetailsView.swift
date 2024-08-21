//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct OutboxDetailsView<T: Server>: View {
    
    @StateObject var outboxReportVM : OutboxMainViewModel<T>
    @StateObject var reportsViewModel : ReportsMainViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                outboxReportHeaderView
                
                ZStack {
                    
                    reportDetails
                    
                    buttonView
                }
            }
            
            if outboxReportVM.isLoading {
                CircularActivityIndicatory()
            }
        }
        
        .onReceive(outboxReportVM.$shouldShowSubmittedReportView, perform: { value in
            if value {
                navigateTo(destination: submittedDetailsView)
            }
        })
        
        .onReceive(outboxReportVM.$shouldShowMainView, perform: { value in
            if value {
                dismissView()
            }
        })
        
        .navigationBarHidden(true)
    }
    
    var outboxReportHeaderView: some View {
        
        HStack(spacing: 0) {
            Button {
                dismissView()
            } label: {
                Image("back")
                    .flipsForRightToLeftLayoutDirection(true)
                    .padding()
            }
            
            Text(LocalizableReport.reportsText.localized)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                showDeleteReportConfirmationView()
            } label: {
                Image("report.delete-outbox")
                    .padding(.all, 22)
            }
        }.frame(height: 56)
    }
    
    private var reportDetails :some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                reportInformations
                
                Spacer()
                    .frame(height: 16)
                
                itemsListView
            }
        }.padding(EdgeInsets(top: 20, leading: 16, bottom: 70, trailing: 16))
    }
    
    private var buttonView :some View {
        VStack {
            Spacer()
            TellaButtonView<AnyView> (title: outboxReportVM.uploadButtonTitle,
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      destination: nil,
                                      isValid: .constant(true)) {
                outboxReportVM.isSubmissionInProgress ? outboxReportVM.pauseSubmission() : outboxReportVM.submitReport()
                
            }
            .padding(EdgeInsets(top: 30, leading: 24, bottom: 16, trailing: 24))
        }
    }
    
    private var reportInformations: some View {
        Group {
            Text(outboxReportVM.reportViewModel.title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            if outboxReportVM.reportHasFile {
                uploadProgressView
            } else {
                Spacer()
                    .frame(height: 16)
            }
            
            Text(outboxReportVM.reportViewModel.description)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            Spacer()
                .frame(height: 16)
            
            if outboxReportVM.reportHasFile {
                Divider()
                    .background(Color.white)
            }
        }
    }
    
    private var uploadProgressView : some View {
        
        Group {
            
            Spacer()
                .frame(height: 8)
            
            Text(outboxReportVM.percentUploadedInfo)
                .font(.custom(Styles.Fonts.italicRobotoFontName, size: 13))
                .foregroundColor(.white)
            Spacer()
                .frame(height: 4)
            
            Text(outboxReportVM.uploadedFiles)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            
            if outboxReportVM.percentUploaded > 0.0 {
                ProgressView("", value: outboxReportVM.percentUploaded, total: 1)
                    .accentColor(.green)
                if outboxReportVM.reportHasDescription{
                    Spacer()
                        .frame(height: 16)
                }
            } else {
                if outboxReportVM.reportHasDescription{
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }
    
    private var itemsListView: some View {
        LazyVStack(spacing: 1) {
            ForEach($outboxReportVM.progressFileItems, id: \.file.id) { file in
                OutboxDetailsItemView(item: file)
                    .frame(height: 60)
            }
        }
    }
    
    private var submittedDetailsView: some View {
        Group {
            switch reportsViewModel.connectionType {
            case .tella:
                let vm = SubmittedReportVM(mainAppModel: outboxReportVM.mainAppModel, reportId: outboxReportVM.reportViewModel.id)
                SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsViewModel)
            case .gDrive:
                let vm = GDriveSubmittedViewModel(mainAppModel: outboxReportVM.mainAppModel, reportId: outboxReportVM.reportViewModel.id)
                SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsViewModel)
            default:
                Text("")
            }
        }
    }
    
    private func dismissView() {
        self.popTo(UIHostingController<ReportMainView>.self)
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteReportConfirmationView(title: outboxReportVM.reportViewModel.title,
                                         message: LocalizableReport.deleteOutboxReportMessage.localized) {
               Toast.displayToast(message: String(format: LocalizableReport.reportDeletedToast.localized, outboxReportVM.reportViewModel.title))
                outboxReportVM.pauseSubmission()
                dismissView()
                outboxReportVM.deleteReport()
                sheetManager.hide()
            }
        }
    }
}

//struct ReportDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        OutboxDetailsView()
//    }
//}


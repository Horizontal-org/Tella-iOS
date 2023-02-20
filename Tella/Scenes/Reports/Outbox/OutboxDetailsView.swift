//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct OutboxDetailsView: View {
    
    @StateObject var outboxReportVM : OutboxReportVM
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(appModel: MainAppModel,reportsViewModel: ReportsViewModel, reportId : Int?, shouldStartUpload: Bool = false) {
        _outboxReportVM = StateObject(wrappedValue: OutboxReportVM(mainAppModel: appModel, reportsViewModel: reportsViewModel, reportId:reportId, shouldStartUpload: shouldStartUpload))
    }
    
    var body: some View {
        
        NavigationContainerView {
            
            VStack {
                
                outboxReportHeaderView
                
                ZStack {
                    
                    reportDetails
                    
                    buttonView
                }
            }
            
            ReportDetailsViewLink
            
            if outboxReportVM.isLoading {
                CircularActivityIndicatory()
            }
        }
        
        .navigationBarBackButtonHidden(true)
    }
    
    var outboxReportHeaderView: some View {
        
        HStack(spacing: 0) {
            Button {
                dismissView()
            } label: {
                Image("back")
                    .padding()
            }
            
            Text("Report")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                // reportViewModel.deleteReport()
            } label: {
                Image("report.delete-outbox")
                    .padding(.all, 22)
            }.disabled(true)
                .opacity(0.2)
        }.frame(height: 56)
    }
    
    private var reportDetails :some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                reportInformations
                
                Spacer()
                    .frame(width: 16)
                
                itemsListView
            }
        }.padding(EdgeInsets(top: 20, leading: 16, bottom: 70, trailing: 16))
    }
    
    private var buttonView :some View {
        VStack {
            Spacer()
            TellaButtonView<AnyView> (title: outboxReportVM.isSubmissionInProgress ? "Pause" : "Resume",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      destination: nil,
                                      isValid: .constant(true)) {
                outboxReportVM.isSubmissionInProgress ? outboxReportVM.pauseSubmission() : outboxReportVM.submitReport()
                
            }.padding(EdgeInsets(top: 30, leading: 24, bottom: 16, trailing: 24))
        }
    }
    
    private var reportInformations: some View {
        Group {
            Text(outboxReportVM.reportViewModel.title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            uploadProgressView
            
            Text(outboxReportVM.reportViewModel.description)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            Spacer()
                .frame(width: 16)
            
            Divider()
                .background(Color.white)
        }
    }
    
    private var uploadProgressView : some View {
        
        Group {
            
            Spacer()
                .frame(width: 8)
            
            Text(outboxReportVM.percentUploadedInfo)
                .font(.custom(Styles.Fonts.italicRobotoFontName, size: 13))
                .foregroundColor(.white)
            Spacer()
                .frame(width: 4)
            
            Text(outboxReportVM.uploadedFiles)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            
            if outboxReportVM.percentUploaded > 0.0 {
                ProgressView("", value: outboxReportVM.percentUploaded, total: 1)
                    .accentColor(.green)
                
                Spacer()
                    .frame(width: 24)
            } else {
                
                Spacer()
                    .frame(width: 20)
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
    
    private var ReportDetailsViewLink: some View {
        SubmittedDetailsView(appModel: mainAppModel,
                             reportId: outboxReportVM.reportViewModel.id)
        .environmentObject(reportsViewModel)
        .addNavigationLink(isActive: $outboxReportVM.shouldShowSubmittedReportView)
    }
    
    private func dismissView() {
        reportsViewModel.newReportRootLinkIsActive = false
        reportsViewModel.editRootLinkIsActive = false
    }
    
}

//struct ReportDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        OutboxDetailsView()
//    }
//}


//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct SubmittedDetailsView: View {
    
    @StateObject var submittedReportVM : SubmittedMainViewModel
    @EnvironmentObject var reportsViewModel : ReportsMainViewModel
    @StateObject var reportsViewModel : ReportMainViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body: some View {
        
        ContainerView {
            
            VStack {
                
                outboxReportHeaderView
                
                ZStack {
                    
                    ScrollView {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            reportDetails
                            
                            Spacer()
                                .frame(width: 16)
                            
                            itemsListView
                        }
                    }.padding(EdgeInsets(top: 20, leading: 16, bottom: 70, trailing: 16))
                }
            }
        }.navigationBarHidden(true)

    }
    
    var outboxReportHeaderView: some View {
        
        HStack(spacing: 0) {
            Button {
                dismissViews()
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
    
    
    private var reportDetails: some View {
        Group {
            Text(submittedReportVM.title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            Spacer()
                .frame(height: 4)
            
            uploadInfosView
            
            if submittedReportVM.reportHasDescription {
                
                Spacer()
                    .frame(height: 12)
                
                Text(submittedReportVM.description)
                    .font(.custom(Styles.Fonts.regularFontName, size: 13))
                    .foregroundColor(.white)
                
            }
            Spacer()
                .frame(height: 18)
            
            if submittedReportVM.reportHasFile {
                Divider()
                    .background(Color.white)
            }
        }
    }
    
    private var uploadInfosView : some View {
        
        Group {
            Text(submittedReportVM.uploadedDate)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
            
            Spacer()
                .frame(height: 2)
            
            if submittedReportVM.reportHasFile {
                Text(submittedReportVM.uploadedFiles)
                    .font(.custom(Styles.Fonts.regularFontName, size: 13))
                    .foregroundColor(.white)
            }
            
        }
    }
    
    private var itemsListView: some View {
        LazyVStack(spacing: 1) {
            ForEach($submittedReportVM.progressFileItems, id: \.file.id) { file in
                SubmittedDetailsItemView(item: file)
                    .frame(height: 60)
            }
        }
    }
    
    private func dismissViews() {
        self.reportsViewModel.selectedPage = .submitted
        self.popTo(UIHostingController<ReportMainView>.self)
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteReportConfirmationView(title: submittedReportVM.title,
                                         message: LocalizableReport.deleteSubmittedReportMessage.localized) {
                dismissViews()
                submittedReportVM.deleteReport()
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

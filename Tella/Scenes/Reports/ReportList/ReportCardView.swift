//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReportCardView : View {
    
    @Binding var report : Report
    
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body : some View {
        
        VStack(spacing: 0) {
            
            HStack {
                
                reportDetails
                
                Spacer()
                    .frame(minWidth: 20)
                
                moreButtonView
                
            }.padding(.all, 16)
            
        } .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
    }
    
    private var reportDetails : some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            Text(report.title ?? "")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            Text(report.getReportDate)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(.white)
        }
    }
    
    private var moreButtonView : some View {
        Button {
            reportsViewModel.selectedReport = report
            showReportActionBottomSheet()
            
        } label: {
            Image("reports.more")
                .padding()
        }
    }
    
    private func showReportActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: report.status == .submitted ? reportsViewModel.submittedReportItems : reportsViewModel.nonSubmittedReportItems,
                                  headerTitle: reportsViewModel.selectedReport?.title ?? "",
                                  action: { item in
                self.handleActions(item : item)
            })
        }
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteReportConfirmationView {
                reportsViewModel.deleteReport()
                sheetManager.hide()
            }
        }
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? ReportActionType else { return  }
        
        switch type {
        case .edit:
            reportsViewModel.editRootLinkIsActive = true
            sheetManager.hide()
        case .delete:
            showDeleteReportConfirmationView()
        case .view:
            reportsViewModel.viewReportLinkIsActive = true
            sheetManager.hide()
        }
    }
}

struct ReportCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            ReportCardView(report: .constant(Report(title: "Title",
                                                    description: "Description",
                                                    date: Date(),
                                                    status: .draft,
                                                    server: Server(), vaultFiles: [])))
        }
    }
}

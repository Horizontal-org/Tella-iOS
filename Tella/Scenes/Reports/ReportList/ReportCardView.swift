//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReportCardView : View {
    
    @Binding var report : Report
    
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel : MainAppModel
    
    var body : some View {
        Button {
            reportsViewModel.selectedReport = report
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.handleActions(type: report.status.reportActionType)
            }
            
        } label: {
            VStack(spacing: 0) {
                
                HStack {
                    
                    ConnectionCardDetails(title: report.title ?? "", subtitle: report.getReportDate)
                    
                    Spacer()
                    
                    ImageButtonView(imageName: "reports.more", action: {
                        reportsViewModel.selectedReport = report
                        showReportActionBottomSheet()
                    })
                    
                }.padding(.all, 16)
                
            } .background(Color.white.opacity(0.08))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        }
    }
    
    
    private func showReportActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: reportsViewModel.sheetItems  ,
                                  headerTitle: reportsViewModel.selectedReport?.title ?? "",
                                  action: { item in
                self.handleActions(type : item.type as? ConnectionActionType)
            })
        }
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteReportConfirmationView(title: report.title,
                                         message: deleteMessage) {
                reportsViewModel.deleteReport(report: report)
                sheetManager.hide()
            }
        }
    }
    
    private func handleActions(type: ConnectionActionType?) {
        
        guard let type else { return }
        
        switch type {
        case .editDraft:
            self.navigateTo(destination: editDraftReportView)
            sheetManager.hide()
        case .editOutbox:
            navigateTo(destination: outboxDetailsView)
            sheetManager.hide()
        case .delete:
            showDeleteReportConfirmationView()
        case .viewSubmitted:
            navigateTo(destination: submittedDetailsView)
            sheetManager.hide()
        }
    }
    
    private var editDraftReportView: some View {
        DraftReportView(mainAppModel: mainAppModel,
                        reportId: reportsViewModel.selectedReport?.id)
        .environmentObject(reportsViewModel)
    }
    
    private var submittedDetailsView: some View {
        SubmittedDetailsView(appModel: mainAppModel,
                             reportId: reportsViewModel.selectedReport?.id)
        .environmentObject(reportsViewModel)
    }
    
    private var outboxDetailsView: some View {
        OutboxDetailsView(appModel: mainAppModel,
                          reportsViewModel: reportsViewModel,
                          reportId: reportsViewModel.selectedReport?.id)
        .environmentObject(reportsViewModel)
    }
    
    private var deleteMessage : String {
        switch report.status {
        case .draft:
            return LocalizableReport.deleteDraftReportMessage.localized
        case .submitted:
            return LocalizableReport.deleteSubmittedReportMessage.localized
        default:
            return LocalizableReport.deleteOutboxReportMessage.localized
        }
    }
}

struct ReportCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            ReportCardView(report: .constant(Report(title: LocalizableReport.reportsListTitle.localized,
                                                    description: LocalizableReport.reportsListDescription.localized,
                                                    status: .draft,
                                                    server: TellaServer(autoUpload: false, autoDelete: true), vaultFiles: [])))
        }
    }
}

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
    
    @State var shouldShowEditReport : Bool = false

    var body : some View {
        
        VStack(spacing: 0) {
            HStack {
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text(report.title ?? "")
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white)
                    
                    Text(report.getReportDate)
                        .font(.custom(Styles.Fonts.regularFontName, size: 12))
                        .foregroundColor(.white)
                }
                
                Spacer()
                    .frame(minWidth: 20)
                
                Button {
                    reportsViewModel.selectedReport = report
                    showReportActionBottomSheet()
                    
                } label: {
                    Image("reports.more")
                        .padding()
                }
            }.padding(.all, 16)
            
            nextViewLink
        } .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 17))

    }
    
    private var nextViewLink: some View {
        DraftReportView(mainAppModel: mainAppModel, isPresented: $shouldShowEditReport, report: reportsViewModel.selectedReport)                .addNavigationLink(isActive: $shouldShowEditReport)
    }

    private func showReportActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: serverActionItems,
                                  headerTitle: reportsViewModel.selectedReport?.title ?? "",
                                  action:  {item in
                self.handleActions(item : item)
            })
        }
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Delete report",
                               msgText: "Are you sure you want to delete this draft?",
                               cancelText: "CANCEL",
                               actionText: "DELETE", didConfirmAction: {
                
                // Delete action
                reportsViewModel.deleteReport()
                sheetManager.hide()
            })
        }
    }
    
    private func handleActions(item: ListActionSheetItem) {
        
        guard let type = item.type as? ServerActionType else { return  }
        
        switch type {
        case .edit:
            shouldShowEditReport = true
            sheetManager.hide()
        case .delete:
            showDeleteReportConfirmationView()
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

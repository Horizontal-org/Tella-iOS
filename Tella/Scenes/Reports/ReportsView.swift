//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI


enum ReportPaths {
    case reportMain
    case draft
    case outbox
    case submitted
}

struct ReportsView: View {
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @StateObject private var reportsViewModel : ReportsViewModel
    @EnvironmentObject var sheetManager : SheetManager
    
    init(mainAppModel:MainAppModel) {
        _reportsViewModel = StateObject(wrappedValue: ReportsViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        
        contentView
            .navigationBarTitle(LocalizableReport.reportsTitle.localized, displayMode: .large)
            .environmentObject(reportsViewModel)
    }
    
    private var contentView :some View {
        
        ContainerView {
            ReportsPageView(
                selectedCell: $reportsViewModel.selectedCell,
                pageViewItems: $reportsViewModel.pageViewItems,
                draftReports: $reportsViewModel.draftReports,
                outboxedReports: $reportsViewModel.outboxedReports,
                submittedReports: $reportsViewModel.submittedReports,
                navigateToAction: { navigateTo(destination: newDraftReportView) }
            )
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        
        .if(self.reportsViewModel.selectedCell == .submitted && self.reportsViewModel.submittedReports.count > 0, transform: { view in
            view.toolbar {
                TrailingButtonToolbar(title: LocalizableReport.clearAppBar.localized) {
                    showDeleteReportConfirmationView()
                }
            }
        })
            
            
    }
    
    private var newDraftReportView: some View {
        DraftReportView(mainAppModel: mainAppModel).environmentObject(reportsViewModel)
    }
    
    var backButton : some View {
        Button {
            self.popToRoot()
        } label: {
            Image("back")
                .flipsForRightToLeftLayoutDirection(true)
                .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
        }
    }
    
    private func showDeleteReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            
            
            ConfirmBottomSheet(titleText: LocalizableReport.clearSheetTitle.localized,
                               msgText: LocalizableReport.clearSheetExpl.localized,
                               cancelText: LocalizableReport.clearCancel.localized,
                               actionText: LocalizableReport.clearSubmitted.localized, didConfirmAction: {
                sheetManager.hide()
                reportsViewModel.deleteSubmittedReport()
                Toast.displayToast(message: LocalizableReport.allReportDeletedToast.localized)
            })
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView(mainAppModel: MainAppModel.stub())
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

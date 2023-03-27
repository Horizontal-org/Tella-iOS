//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct ReportsView: View {
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @StateObject private var reportsViewModel : ReportsViewModel
    
    init(mainAppModel:MainAppModel, serverLinkIsActive : Binding<Bool> = .constant(false)) {
        _reportsViewModel = StateObject(wrappedValue: ReportsViewModel(mainAppModel: mainAppModel, serverLinkIsActive: serverLinkIsActive))
    }
    
    var body: some View {
        
        contentView
            .navigationBarTitle(LocalizableReport.reportsTitle.localized, displayMode: .large)
            .environmentObject(reportsViewModel)
        
        newReportLink
        editReportViewLink
    }
    
    private var contentView :some View {
        ContainerView {
            
            VStack(alignment: .center) {
                
                PageView(selectedOption: self.$reportsViewModel.selectedCell, pageViewItems: $reportsViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    switch self.reportsViewModel.selectedCell {
                        
                    case .draft:
                        ReportListView(reportArray: $reportsViewModel.draftReports,
                                       message: LocalizableReport.reportsDraftMessage.localized)
                        
                    case .outbox:
                        
                        ReportListView(reportArray: $reportsViewModel.outboxedReports,
                                       message: LocalizableReport.reportsOutboxMessage.localized)
                        
                    case .submitted:
                        ReportListView(reportArray: $reportsViewModel.submittedReports,
                                       message: LocalizableReport.reportsSubmited.localized)
                    }
                    
                    Spacer()
                }
                
                TellaButtonView<AnyView> (title: LocalizableReport.reportsCreateNew.localized,
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    reportsViewModel.newReportRootLinkIsActive = true
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
    }
    
    @ViewBuilder
    private var newReportLink: some View {
        if reportsViewModel.newReportRootLinkIsActive {
            DraftReportView(mainAppModel: mainAppModel)
                .environmentObject(reportsViewModel)
                .addNavigationLink(isActive: $reportsViewModel.newReportRootLinkIsActive,shouldAddEmptyView: true)
        }
    }
    
    @ViewBuilder
    private var editReportViewLink: some View {
        
        switch reportsViewModel.selectedReport?.status {
            
        case .draft:
            if reportsViewModel.editRootLinkIsActive {
                
                DraftReportView(mainAppModel: mainAppModel,
                                reportId: reportsViewModel.selectedReport?.id)
                .environmentObject(reportsViewModel)
                .addNavigationLink(isActive: $reportsViewModel.editRootLinkIsActive)
            }
        case .submitted:
            if reportsViewModel.viewReportLinkIsActive {
                
                SubmittedDetailsView(appModel: mainAppModel,
                                     reportId: reportsViewModel.selectedReport?.id)
                .environmentObject(reportsViewModel)
                .addNavigationLink(isActive: $reportsViewModel.viewReportLinkIsActive)
            }
        default:
            if reportsViewModel.editRootLinkIsActive {
                
                OutboxDetailsView(appModel: mainAppModel,
                                  reportsViewModel: reportsViewModel,
                                  reportId: reportsViewModel.selectedReport?.id)
                .environmentObject(reportsViewModel)
                .addNavigationLink(isActive: $reportsViewModel.editRootLinkIsActive)
            }
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView(mainAppModel: MainAppModel())
    }
}


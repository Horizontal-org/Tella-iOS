//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TellaServerDraftView: View {
    
    @StateObject var draftReportViewModel: DraftReportVM
    
    var reportsViewModel: ReportsMainViewModel
    
    init(reportId:Int? = nil, reportsViewModel: ReportsMainViewModel) {
        _draftReportViewModel = StateObject(wrappedValue: DraftReportVM(reportId:reportId, reportsMainViewModel: reportsViewModel))
        self.reportsViewModel = reportsViewModel
    }
    
    var body: some View {
        DraftView(viewModel: draftReportViewModel, showOutboxDetailsViewAction: {
            showOutboxDetailsView()
        })
    }
    
    private func showOutboxDetailsView() {
        let outboxVM = OutboxReportVM(reportsViewModel: draftReportViewModel.reportsMainViewModel, reportId: draftReportViewModel.reportId)
        navigateTo(destination: TellaServerOutboxDetailsView(outboxReportVM: outboxVM))
    }
    
}

//struct DraftReportView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        TellaServerDraftView(mainAppModel: MainAppModel.stub())
//    }
//}



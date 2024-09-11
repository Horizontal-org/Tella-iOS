//
//  NextcloudReportMainView.swift
//  Tella
//
//  Created by RIMA on 5/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct NextcloudReportMainView: View {
    
    @ObservedObject var reportsMainViewModel: NextcloudReportViewModel
    
    var body: some View {
        ReportMainView(reportsMainViewModel: reportsMainViewModel) { id in
            var destination : any View
            destination = NextcloudDraftView(nextcloudDraftViewModel: NextcloudDraftViewModel(repository: reportsMainViewModel.nextcloudRepository, reportId: id, reportsMainViewModel: reportsMainViewModel))
            
            self.navigateTo(destination: destination)
            
        } showSubmittedViewAction: { id in
            let vm = NextcloudSubmittedViewModel(reportsMainViewModel: reportsMainViewModel, reportId: id)
            let destination = NextcloudSubmittedDetailsView(submittedMainViewModel: vm, reportsMainViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
            
        } showOutboxViewAction: { id in
            let outboxViewModel = NextcloudOutboxViewModel(reportsViewModel: reportsMainViewModel,
                                                           reportId: id,
                                                           repository:reportsMainViewModel.nextcloudRepository)
            let destination = NextcloutOutboxDetailsView(outboxReportVM: outboxViewModel)
            
            self.navigateTo(destination: destination)
            
        }
        
    }
}

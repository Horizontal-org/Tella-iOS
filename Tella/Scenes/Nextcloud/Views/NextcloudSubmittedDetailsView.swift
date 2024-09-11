//
//  NextcloudSubmittedDetailsView.swift
//  Tella
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//


import SwiftUI

struct NextcloudSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: NextcloudSubmittedViewModel
    @StateObject var reportsMainViewModel: ReportsMainViewModel
    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, reportsViewModel: reportsMainViewModel, rootView: ViewClassType.nextcloudReportMainView)
    }
}

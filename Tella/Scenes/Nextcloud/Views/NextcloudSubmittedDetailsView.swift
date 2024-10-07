//
//  NextcloudSubmittedDetailsView.swift
//  Tella
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//


import SwiftUI

struct NextcloudSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: NextcloudSubmittedViewModel

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.nextcloudReportMainView)
    }
}

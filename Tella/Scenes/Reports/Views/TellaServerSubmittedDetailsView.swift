//
//  TellaServerSubmittedDetailsView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct TellaServerSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: SubmittedReportVM

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.tellaServerReportMainView)
    }
}

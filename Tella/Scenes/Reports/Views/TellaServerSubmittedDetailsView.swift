//
//  TellaServerSubmittedDetailsView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
struct TellaServerSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: SubmittedReportVM

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.tellaServerReportMainView)
    }
}

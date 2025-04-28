//
//  NextcloudSubmittedDetailsView.swift
//  Tella
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import SwiftUI

struct NextcloudSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: NextcloudSubmittedViewModel

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.nextcloudReportMainView)
    }
}

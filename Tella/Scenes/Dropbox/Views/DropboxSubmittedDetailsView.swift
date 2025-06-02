//
//  DropboxSubmittedDetailsView.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct DropboxSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: DropboxSubmittedViewModel

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.dropboxReportMainView)
    }
}

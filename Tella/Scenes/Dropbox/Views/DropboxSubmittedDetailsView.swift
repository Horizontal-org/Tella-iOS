//
//  DropboxSubmittedDetailsView.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct DropboxSubmittedDetailsView: View {
    
    @StateObject var submittedMainViewModel: DropboxSubmittedViewModel

    var body: some View {
        SubmittedDetailsView(submittedReportVM: submittedMainViewModel, rootView: ViewClassType.dropboxReportMainView)
    }
}

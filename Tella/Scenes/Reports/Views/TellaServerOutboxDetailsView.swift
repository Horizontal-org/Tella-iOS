//
//  TellaServerOutboxDetailsView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct TellaServerOutboxDetailsView<T: TellaServer>: View {
    
    @StateObject var outboxReportVM : OutboxMainViewModel<T>
    @StateObject var reportsViewModel : ReportsMainViewModel
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM,
                          reportsViewModel: reportsViewModel, rootView: ViewClassType.tellaServerReportMainView)
        
    }
}


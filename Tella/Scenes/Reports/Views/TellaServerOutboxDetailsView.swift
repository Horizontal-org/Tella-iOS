//
//  TellaServerOutboxDetailsView.swift
//  Tella
//
//  Created by RIMA on 6/9/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
struct TellaServerOutboxDetailsView<T: TellaServer>: View {
    
    @StateObject var outboxReportVM: OutboxReportVM
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM, rootView: ViewClassType.tellaServerReportMainView)
        
    }
}


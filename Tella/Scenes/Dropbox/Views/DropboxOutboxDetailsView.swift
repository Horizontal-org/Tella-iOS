//
//  DropboxOutboxDetailsView.swift
//  Tella
//
//  Created by gus valbuena on 9/19/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DropboxOutboxDetailsView<T: DropboxServer>: View {
    @StateObject var outboxReportVM: OutboxMainViewModel<T>
    
    var body: some View {
        OutboxDetailsView(outboxReportVM: outboxReportVM, rootView: ViewClassType.dropboxReportMainView)
    }
}

//
//  GDriveDraftView.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GDriveDraftView: View {
    @StateObject var gDriveDraftVM: GDriveDraftViewModel
    @StateObject var reportsViewModel : ReportsMainViewModel
    var body: some View {
        DraftView(viewModel: gDriveDraftVM, reportsViewModel: reportsViewModel)
    }
}
//
//#Preview {
//    GDriveDraftView(mainAppModel: MainAppModel.stub()) //TOFix
//}

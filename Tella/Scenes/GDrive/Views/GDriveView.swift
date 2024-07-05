//
//  GDriveView.swift
//  Tella
//
//  Created by gus valbuena on 6/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GDriveView: View {
    @EnvironmentObject var mainAppModel: MainAppModel
    @StateObject var gDriveViewModel: GDriveViewModel
    let gDriveDIContainer = GDriveDIContainer()
    
    init(mainAppModel: MainAppModel) {
        _gDriveViewModel = StateObject(wrappedValue: GDriveViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        contentView
            .navigationBarTitle(LocalizableSettings.settServerGDrive.localized.capitalized, displayMode: .large)
            .environmentObject(gDriveViewModel)
    }
    
    var contentView: some View {
        ContainerView {
            VStack(alignment: .center) {
                PageView(selectedOption: self.$gDriveViewModel.selectedCell, pageViewItems: gDriveViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack {
                    Spacer()
                    switch self.gDriveViewModel.selectedCell {
                    case .draft:
                        GDriveListView(reportArray: $gDriveViewModel.draftReports, message: "You have no draft reports.")
                    case .outbox:
                        GDriveListView(reportArray: $gDriveViewModel.outboxedReports, message: "You have no outbox reports.")
                    case .submitted:
                        GDriveListView(reportArray: $gDriveViewModel.submittedReports, message: "You have no submitted reports.")
                    default:
                        EmptyView()
                    }
                    Spacer()
                }
                createGDriveReportButton
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
    }
    
    var createGDriveReportButton: some View {
        TellaButtonView<AnyView> (title: LocalizableReport.reportsCreateNew.localized,
                                  nextButtonAction: .action,
                                  buttonType: .yellow,
                                  isValid: .constant(true)) {
            navigateTo(destination: newGDriveDraftView)
        } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var newGDriveDraftView: some View {
        GDriveDraftView(mainAppModel: mainAppModel, gDriveDIContainer: gDriveDIContainer)
            .environmentObject(gDriveViewModel)
    }
}

#Preview {
    GDriveView(mainAppModel: MainAppModel.stub())
}

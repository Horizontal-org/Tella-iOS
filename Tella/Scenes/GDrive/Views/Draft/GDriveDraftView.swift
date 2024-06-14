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
    let gDriveDIContainer: GDriveDIContainer
    
    init(mainAppModel: MainAppModel, gDriveDIContainer: GDriveDIContainer) {
        self.gDriveDIContainer = gDriveDIContainer
        _gDriveDraftVM = StateObject(wrappedValue: GDriveDraftViewModel(
            mainAppModel: mainAppModel,
            repository: gDriveDIContainer.gDriveRepository)
        )
    }
    var body: some View {
        ContainerView {
            VStack(alignment: .leading) {
                headerView
                contentView
                Spacer()
                bottomButtonsView
            }
        }.navigationBarHidden(true)
    }
    
    var headerView: some View {
        NavigationHeaderView(type: .draft)
    }
    
    var contentView: some View {
        VStack {
            TextfieldView(
              fieldContent: $gDriveDraftVM.title,
              isValid: $gDriveDraftVM.isValidTitle,
              shouldShowError: $gDriveDraftVM.shouldShowError,
              fieldType: .text,
              placeholder: LocalizableReport.reportsListTitle.localized,
              shouldShowTitle: true)

            Spacer()
              .frame(height: 34)

            UnderlinedTextEditorView(
              placeholder: LocalizableReport.reportsListDescription.localized,
              fieldContent: $gDriveDraftVM.description,
              isValid: $gDriveDraftVM.isValidDescription,
              shouldShowError: $gDriveDraftVM.shouldShowError,
              shouldShowTitle: true)

            Spacer()
              .frame(height: 24)
        }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    var bottomButtonsView: some View {
        HStack {
            submitLaterButton
            submitButton
        }.padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
    }
    
    var submitLaterButton: some View {
      Button {
          
      } label: {
          Image("reports.submit-later")
              .opacity(0.4)
      }.disabled(true)
    }

    var submitButton: some View {
      TellaButtonView<AnyView>(
        title: LocalizableReport.reportsSubmit.localized,
        nextButtonAction: .action,
        buttonType: .yellow,
        isValid: .constant(true)
      ) {
          gDriveDraftVM.submitReport()
      }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }

}

#Preview {
    GDriveDraftView(mainAppModel: MainAppModel.stub(), gDriveDIContainer: GDriveDIContainer())
}

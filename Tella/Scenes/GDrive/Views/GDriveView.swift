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
    
    init(mainAppModel: MainAppModel) {
        _gDriveViewModel = StateObject(wrappedValue: GDriveViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        contentView
            .navigationBarTitle(LocalizableSettings.settServerGDrive.localized.capitalized, displayMode: .large)
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
                        GDriveListView(message: "You have no draft reports.")
                    case .outbox:
                        GDriveListView(message: "You have no outbox reports.")
                    case .submitted:
                        GDriveListView(message: "You have no submitted reports.")
                    default:
                        EmptyView()
                    }
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
    }
}

#Preview {
    GDriveView(mainAppModel: MainAppModel.stub())
}

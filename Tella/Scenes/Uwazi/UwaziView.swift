//
//  UwaziView.swift
//  Tella
//
//  Created by Gustavo on 27/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziView: View {
    @EnvironmentObject var mainAppModel : MainAppModel
    @StateObject private var uwaziReportsViewModel : UwaziReportsViewModel
    @EnvironmentObject var sheetManager : SheetManager
    
    init(mainAppModel: MainAppModel) {
        _uwaziReportsViewModel = StateObject(wrappedValue: UwaziReportsViewModel(mainAppModel: mainAppModel))
    }
    var body: some View {
        contentView
            .navigationBarTitle("Uwazi", displayMode: .large)
            .environmentObject(uwaziReportsViewModel)
    }
    
    private var contentView :some View {
            
            ContainerView {
                ReportsPageView(
                    selectedCell: $uwaziReportsViewModel.selectedCell,
                    pageViewItems: $uwaziReportsViewModel.pageViewItems,
                    draftReports: $uwaziReportsViewModel.draftReports,
                    outboxedReports: $uwaziReportsViewModel.outboxedReports,
                    submittedReports: $uwaziReportsViewModel.submittedReports,
                    navigateToAction: {  }
                )
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
                
        }
    
    var backButton : some View {
            Button {
                self.popToRoot()
            } label: {
                Image("back")
                    .flipsForRightToLeftLayoutDirection(true)
                    .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
            }
        }
    

}

struct UwaziView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView(mainAppModel: MainAppModel.stub())
    }
}

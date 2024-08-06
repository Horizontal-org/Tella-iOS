//
//  NextcloudDraftView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct NextcloudDraftView: View {
    
    @StateObject var nextcloudDraftViewModel: NextcloudDraftViewModel
    @StateObject var reportsViewModel : ReportsMainViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    
    let nextcloudDIContainer: NextcloudDIContainer
    
    init(mainAppModel: MainAppModel,
         nextcloudDIContainer: NextcloudDIContainer,
         reportsViewModel: ReportsMainViewModel,
         reportId: Int? = nil) {
        
        self.nextcloudDIContainer = nextcloudDIContainer
        _reportsViewModel = StateObject(wrappedValue: reportsViewModel)
        _nextcloudDraftViewModel = StateObject(wrappedValue: NextcloudDraftViewModel(mainAppModel: mainAppModel,
                                                                                     repository: nextcloudDIContainer.nextcloudRepository,
                                                                                     reportId: reportId))
    }
    
    var body: some View {
        DraftView(viewModel: nextcloudDraftViewModel, reportsViewModel: reportsViewModel)
    }
}

#Preview {
    NextcloudDraftView(mainAppModel: MainAppModel.stub(),
                       nextcloudDIContainer: NextcloudDIContainer(),
                       reportsViewModel: ReportsMainViewModel.stub())
}

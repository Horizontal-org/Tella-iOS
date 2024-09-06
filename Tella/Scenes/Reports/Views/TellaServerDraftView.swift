//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TellaServerDraftView: View {
    
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    var reportsViewModel: ReportsMainViewModel
    
    init(mainAppModel: MainAppModel, reportId:Int? = nil, reportsViewModel: ReportsMainViewModel) {
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(mainAppModel: mainAppModel,reportId:reportId))
        self.reportsViewModel = reportsViewModel
    }
    
    var body: some View {
        DraftView(viewModel: reportViewModel, reportsViewModel: reportsViewModel)
    }
}

//struct DraftReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        TellaServerDraftView(mainAppModel: MainAppModel.stub())
//    }
//}



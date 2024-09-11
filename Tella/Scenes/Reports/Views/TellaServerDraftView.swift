//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TellaServerDraftView: View {
    
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var sheetManager : SheetManager
    var reportsViewModel: ReportsMainViewModel
    
    init(reportId:Int? = nil, reportsViewModel: ReportsMainViewModel) {
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(reportId:reportId, reportsMainViewModel: reportsViewModel))
        self.reportsViewModel = reportsViewModel
    }
    
    var body: some View {
        DraftView(viewModel: reportViewModel)
    }
}

//struct DraftReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        TellaServerDraftView(mainAppModel: MainAppModel.stub())
//    }
//}



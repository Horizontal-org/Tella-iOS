//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DraftReportView: View {
    
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    @EnvironmentObject var reportsViewModel : ReportsViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(mainAppModel: MainAppModel, reportId:Int? = nil) {
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(mainAppModel: mainAppModel,reportId:reportId))
    }
    
    var body: some View {
        DraftView(viewModel: reportViewModel)
            .environmentObject(reportsViewModel)
    }
}

struct DraftReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        DraftReportView(mainAppModel: MainAppModel.stub())
            .environmentObject(ReportsViewModel(mainAppModel: MainAppModel.stub()))
    }
}


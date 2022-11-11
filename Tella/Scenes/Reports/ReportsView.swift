//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct ReportsView: View {
    
    @EnvironmentObject var mainAppModel : MainAppModel
    
    @StateObject private var reportsViewModel : ReportsViewModel
    @State private var selecetedCell = Pages.draft
    @State private var outBoxCount = 0
    @State private var shouldShowNewReport = false
    
    init(mainAppModel:MainAppModel) {
        _reportsViewModel = StateObject(wrappedValue: ReportsViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
//        NavigationView {
            ZStack(alignment: .top) {
                
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center) {
                    
                    PageView(selectedOption: self.$selecetedCell, outboxCount: self.$outBoxCount)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding([.leading, .trailing], 10)
                    
                    VStack (spacing: 0) {
                        Spacer()
                        
                        switch self.selecetedCell {
                            
                        case .draft:
                            ReportListView(reportArray: $reportsViewModel.draftReports,
                                           message: "Your Drafts is currently empty. Reports that you have not submitted will appear here.")
                            
                        case .outbox:
                            
                            ReportListView(reportArray: $reportsViewModel.outboxedReports,
                                           message: "Your Outbox is currently empty. Reports that are ready to be sent will appear here.")
                            
                        case .submitted:
                            ReportListView(reportArray: $reportsViewModel.submittedReports,
                                           message: "You have no submitted reports.")
                        }
                        
                        Spacer()
                        
                    }
                    
//                    TellaButtonView<AnyView> (title: "NEW REPORT",
//                                              nextButtonAction: .action,
//                                              buttonType: .yellow,
//                                              isValid: .constant(true)) {
//                        shouldShowNewReport = true
//                    }.padding(EdgeInsets(top: 30, leading: 24, bottom: 16, trailing: 24))
//
                    
                    TellaButtonView (title: "NEW REPORT",
                                              nextButtonAction: .destination,
                                              buttonType: .yellow,
                                              destination: DraftReportView(mainAppModel: mainAppModel, isPresented: $shouldShowNewReport),
                                              isValid: .constant(true)) {
//                        shouldShowNewReport = true
                    }.padding(EdgeInsets(top: 30, leading: 24, bottom: 16, trailing: 24))

                    
                }
                .background(Styles.Colors.backgroundMain)
            }
            .navigationBarTitle("Reports")
            .background(Styles.Colors.backgroundMain)
            
//            .fullScreenCover(isPresented: $shouldShowNewReport, content: {
//                DraftReportView(mainAppModel: mainAppModel, isPresented: $shouldShowNewReport)
//            })
            
            .environmentObject(reportsViewModel)

//        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView(mainAppModel: MainAppModel())
    }
}


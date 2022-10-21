//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct ReportsView: View {
    
    @StateObject var reportViewModel : ReportsViewModel

    @State var selecetedCell = Pages.draft
    @State var outBoxCount = 0
    
    @State var shouldShowNewReport = false
    @EnvironmentObject var mainAppModel : MainAppModel

    init(mainAppModel:MainAppModel) {
        _reportViewModel = StateObject(wrappedValue: ReportsViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
               
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
               
                VStack(alignment: .leading) {
                    
                    PageView(selectedOption: self.$selecetedCell, outboxCount: self.$outBoxCount)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding([.leading, .trailing], 10)
                   
                    VStack {
                        Spacer()
                        switch self.selecetedCell {
                            
                        case .draft:
                            
                            EmptyReportView()
                            
                        case .outbox:
                            VStack(alignment: .leading) {
                                Text("Outbox")
                            }
                            
                        case .submitted:
                            VStack(alignment: .leading) {
                                Text("Sent")
                            }
                        }
                        Spacer()

                    }
                    
                    
                    TellaButtonView<AnyView> (title: "NEW REPORT",
                                              nextButtonAction: .action,
                                              buttonType: .yellow,
                                              isValid: .constant(true)) {

                        // display new report
                        shouldShowNewReport = true
                        
                    }.padding(EdgeInsets(top: 30, leading: 24, bottom: 16, trailing: 24))

                    
                    
                }
                .background(Styles.Colors.backgroundMain)
            }
            .navigationBarTitle("Reports")
            .background(Styles.Colors.backgroundMain)
           
            .fullScreenCover(isPresented: $shouldShowNewReport, content: {
                DraftReportView(isPresented: $shouldShowNewReport)
                    .environmentObject(reportViewModel)
            })

        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView(mainAppModel: MainAppModel())
    }
}


//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct ReportsView: View {
    
    @State var title: String = ""
    @State var description: String = ""
    @State var selecetedCell = Pages.new
    @State var outBoxCount = 0
    
    init() {
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    PageView(selectedOption: self.$selecetedCell, outboxCount: self.$outBoxCount)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding([.leading, .trailing], 10)
                    VStack {
                        switch self.selecetedCell {
                        case .new:
                            NewReportView(title: self.$title, description: self.$description)
                        case .draft:
                            VStack(alignment: .leading) {
                                Text("Draft")
                            }
                        case .outbox:
                            VStack(alignment: .leading) {
                                Text("Outbox")
                            }
                        case .sent:
                            VStack(alignment: .leading) {
                                Text("Sent")
                            }
                        }
                    }
                }
                .background(Color(Styles.Colors.backgroundMain))
            }
            .navigationBarTitle("Reports")
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView()
    }
}


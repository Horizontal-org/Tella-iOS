//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsView: View {
    
    @State var title: String = ""
    @State var description: String = ""
    @State var selecetedCell = Pages.draft
    @State private var selectedTabIndex = 0
    @State var outBoxCount = 0
    var width = UIScreen.main.bounds.width
    
    private let titles = ["Blank","Drafts","OutBox","Sent"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    PageView(selectedOption: self.$selecetedCell, outboxCount: self.$outBoxCount, titles: titles)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding([.leading, .trailing], 10)
                    VStack {
                        switch self.selecetedCell {
                        case .draft:
                            DraftFormsView()
                        case .outbox:
                            OutBoxFormsView()
                        case .submitted:
                            SentFormsView()
                        }
                    }
                }
            }
            .navigationBarTitle("Forms")
            .navigationBarItems(trailing: HeaderView(onRefreshAction: {}, onHelpAction: {}, onNewFormAction: {
                debugLog("New form tap")
                self.outBoxCount+=1
            }) )
        }.highPriorityGesture(DragGesture()
                                .onEnded({ value in
                                    if value.translation.width < 50 {
                                        // left
                                        if (Pages.fromHashValue(hashValue: self.selecetedCell) > 0) {
                                            self.selecetedCell = Pages.fromValueHash(value: Pages.fromHashValue(hashValue: self.selecetedCell)-1)
                                        }
                                    }
                                    if value.translation.width > 50 {
                                        if (Pages.fromHashValue(hashValue: self.selecetedCell) < 3) {
                                            self.selecetedCell = Pages.fromValueHash(value: Pages.fromHashValue(hashValue: self.selecetedCell)+1)
                                        }
                                    }
                                    
                                }))
        
    }
}

struct FormsView_Previews: PreviewProvider {
    static var previews: some View {
        FormsView()
    }
}

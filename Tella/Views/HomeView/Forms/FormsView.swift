//
//  FormsView.swift
//  Tella
//
//  Created by Ahlem on 08/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsView: View {
    @State var title: String = ""
    @State var description: String = ""
    @State var selecetedCell = Pages.new
    @State private var selectedTabIndex = 0
    @State var outBoxCount = 0
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    PageView(selectedOption: self.$selecetedCell, outboxCount: self.$selectedTabIndex,titles: ["Blank","Drafts","OutBox","Sent"])
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding([.leading, .trailing], 10)
                    VStack {
                        switch self.selecetedCell {
                        case .new:
                            BlankFormsView()
                        case .draft:
                            DraftFormsView()
                        case .outbox:
                            OutBoxFormsView()
                        case .sent:
                            SentFormsView()
                        }
                    }
                }
            }
            .navigationBarTitle("Forms")
            .navigationBarItems(trailing: HeaderView(onRefreshClick: {}, onHelpClick: {}, onNewFormClick: {}) )
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
/*NavigationView {
 ZStack(alignment: .top) {
 Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
 VStack(alignment: .leading,spacing : 0){
 
 // TopBarView(index: self.$index, offset: self.$offset)
 TabView(selection : self.$index){
 BlankFormsView()
 .tag(0)
 .tabItem {}
 DraftFormsView()
 .tag(1)
 OutBoxFormsView()
 .tag(2)
 SentFormsView()
 .tag(3)
 
 
 }
 .edgesIgnoringSafeArea(.all)
 .animation(.default)
 .navigationBarTitle("Forms")
 .background(Color(Styles.Colors.backgroundMain))
 .highPriorityGesture(DragGesture()
 .onEnded({ value in
 if value.translation.width < 50 {
 // left
 if (self.index > 0) {
 self.index -= 1
 }
 }
 if value.translation.width > 50 {
 if (self.index < 3) {
 self.index += 1
 }
 }
 if value.translation.height < 50 {
 // up
 }
 
 if value.translation.height > 0 {
 // down
 }
 }))
 }
 
 }                    .navigationBarHidden(true)
 
 
 }                       .navigationBarHidden(true)
 .background(Color(Styles.Colors.backgroundMain))
 
 */


struct FormsView_Previews: PreviewProvider {
    static var previews: some View {
        FormsView()
    }
}

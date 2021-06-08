//
//  FormsView.swift
//  Tella
//
//  Created by Ahlem on 08/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsView: View {
    @State var index = 1
    @State var offset : CGFloat = UIScreen.main.bounds.width
    var width = UIScreen.main.bounds.width
    var body: some View {
        VStack(spacing : 0){
            TopBarView(index: self.$index, offset: self.$offset)
            TabView(selection : self.$index){
                    BlankFormsView()
                        .tag(0)
                        .tabItem {  }
                    
                    DraftFormsView()
                        .tag(1)
                    OutBoxFormsView()
                        .tag(2)
                    SentFormsView()
                        .tag(3)
                }
            
          /*  TopBarView(index: self.$index, offset: self.$offset)
            GeometryReader{ g in
                HStack(spacing : 0){
                   BlankFormsView()
                    .frame(width : g.frame(in: .global).width)
                    DraftFormsView()
                     .frame(width : g.frame(in: .global).width)
                    OutBoxFormsView()
                     .frame(width : g.frame(in: .global).width)
                    SentFormsView()
                     .frame(width : g.frame(in: .global).width)
                }
            }
            .offset(x: self.offset)*/
        }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct FormsView_Previews: PreviewProvider {
    static var previews: some View {
        FormsView()
    }
}

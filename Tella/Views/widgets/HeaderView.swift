//
//  HeaderView.swift
//  Tella
//
//  Created by Ahlem on 07/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var onRefreshClick : () -> ()
    var onHelpClick : () -> ()
    var onNewFormClick : () -> ()
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center ,spacing: 20){
                Button(action: {
                    self.onNewFormClick()
                    print("button fill pressed")
                }) {
                    Image("fill-icon")
                        .renderingMode(.original)
                }
                
                Button(action: {
                    self.onRefreshClick()
                    print("button refresh pressed")
                }) {
                    Image("refresh-icon")
                        .renderingMode(.original)
                }
                
                Button(action: {
                    self.onHelpClick()
                    print("button help pressed")
                }) {
                    Image("help-icon")
                        .renderingMode(.original)
                }.padding(.trailing, 20)
                
            }
            .frame(maxWidth: .infinity, maxHeight : 56,alignment: .trailing)
        }.background(Color(Styles.Colors.backgroundMain))
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        

      
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(onRefreshClick: {}, onHelpClick:{}, onNewFormClick: {})
    }
}

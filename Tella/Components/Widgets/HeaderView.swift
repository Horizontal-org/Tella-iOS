//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct HeaderView: View {
    
    var onRefreshAction : () -> ()
    var onHelpAction : () -> ()
    var onNewFormAction : () -> ()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center ,spacing: 20){
                Button(action: {
                    self.onNewFormAction()
                    debugLog("button fill pressed")
                }) {
                    Image("fill-icon")
                        .renderingMode(.original)
                }
                Button(action: {
                    self.onRefreshAction()
                    debugLog("button refresh pressed")
                }) {
                    Image("refresh-icon")
                        .renderingMode(.original)
                }
                
                Button(action: {
                    self.onHelpAction()
                    debugLog("button help pressed")
                }) {
                    Image("help-icon")
                        .renderingMode(.original)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 66, alignment: .trailing)
        }.background(Styles.Colors.backgroundMain)
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(onRefreshAction: {}, onHelpAction:{}, onNewFormAction: {})
    }
}

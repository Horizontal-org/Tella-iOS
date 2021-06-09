//
//  FormsView.swift
//  Tella
//
//  Created by Ahlem on 08/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsView: View {
    @State var index = 0
    @State var offset : CGFloat = UIScreen.main.bounds.width
    @State private var selectedTabIndex = 0
    var width = UIScreen.main.bounds.width
    var body: some View {
        VStack(alignment: .trailing,spacing : 0){
            TopBarView(index: self.$index, offset: self.$offset)
            SentFormsView()
        }.edgesIgnoringSafeArea(.all)
        .animation(.default)
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
}

struct FormsView_Previews: PreviewProvider {
    static var previews: some View {
        FormsView()
    }
}

//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CustomNavigation<Content:View>: View {
    
    var backgroundColor : Color = Styles.Colors.backgroundMain
    var content : () -> Content
    
    init(backgroundColor: Color = Styles.Colors.backgroundMain, @ViewBuilder content : @escaping () -> Content) {
        self.content = content
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        if #available(iOS 16.0, *) {
            if #available(iOS 17.0, *) {
                NavigationView{
                    self.content()
                    
                } .navigationViewStyle(.stack)
                    .navigationBarHidden(true)
            } else {
                NavigationStack {
                    self.content()
                }
                .navigationBarHidden(true)
            }
        } else {
            NavigationView{
                self.content()
                
            } .navigationViewStyle(.stack)
                .navigationBarHidden(true)
        }
        
    }
}

//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
            } else {
                NavigationStack {
                    self.content()
                }
            }
        } else {
            NavigationView {
                self.content()
                .navigationBarHidden(true)
                .navigationBarTitle("", displayMode: .inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())

        }
        
    }
}

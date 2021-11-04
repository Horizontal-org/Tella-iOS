//
//  CustomNavigationContainerView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CustomNavigationContainerView<Content:View>: View {
    
    var content : () -> Content
    
    init(@ViewBuilder content : @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Styles.Colors.backgroundMain
                    .edgesIgnoringSafeArea(.all)
                self.content()
            }
        }.navigationViewStyle(StackNavigationViewStyle())

    }
}


//struct CustomNavigationContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNavigationContainerView<<#Content: View#>>()
//    }
//}

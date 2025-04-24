//
//  ContainerView.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct NavigationContainerView<Content:View>: View {
    
    var backgroundColor : Color = Styles.Colors.backgroundMain
    var content : () -> Content
    
    init(backgroundColor: Color = Styles.Colors.backgroundMain, @ViewBuilder content : @escaping () -> Content) {
        self.content = content
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        CustomNavigation() {
            ZStack {
                self.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                self.content()
            }
        }
        .accentColor(.white)
    }
}

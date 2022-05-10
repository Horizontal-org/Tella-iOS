//
//  ContainerView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct NavigationContainerView<Content:View>: View {
    
    var backgroundColor : Color
    var content : () -> Content
    
    init(backgroundColor : Color = Styles.Colors.backgroundMain, @ViewBuilder content : @escaping () -> Content) {
        self.content = content
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                self.content()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
        .accentColor(.white)
        .navigationViewStyle(.stack)
        .navigationBarTitle("")
        .navigationBarHidden(true)

    }
}

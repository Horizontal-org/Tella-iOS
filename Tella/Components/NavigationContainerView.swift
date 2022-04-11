//
//  ContainerView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct NavigationContainerView<Content:View>: View {
    
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

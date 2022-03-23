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
        ZStack {
            Styles.Colors.backgroundMain
                .edgesIgnoringSafeArea(.all)
            self.content()
        }
    }
}

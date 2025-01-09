//
//  ContainerView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ContainerView<Content:View>: View {
    
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

// Trying to implement ViewModifier for ContainerView
struct ContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Styles.Colors.backgroundMain
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func containerStyle() -> some View {
        self.modifier(ContainerModifier())
    }
}



struct ContainerViewWithHeader<Header:View,Content:View>: View {
    
    var headerView : () -> Header
    var content : () -> Content
    
    init( @ViewBuilder headerView : @escaping () -> Header, @ViewBuilder content : @escaping () -> Content) {
        self.content = content
        self.headerView = headerView
    }
    
    var body: some View {
        ZStack {
            Styles.Colors.backgroundMain
                .edgesIgnoringSafeArea(.all)
            VStack {
                headerView()
                self.content()
            }
        }
        .navigationBarHidden(true)
        
    }
}

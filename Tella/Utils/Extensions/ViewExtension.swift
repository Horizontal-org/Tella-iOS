//
//  ViewExtension.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
    func navigateTo<Destination: View>( destination: Destination) ->  some View   {
        
        if #available(iOS 15.0, *) {
            
            return  AnyView(NavigationLink(destination: destination) {
                self
            }.buttonStyle(PlainButtonStyle()))
            
        } else {
            return   AnyView(ZStack {
                NavigationLink(destination: destination) {
                    self
                }.buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
                
            })
            
            
        }
    }
    
    func addNavigationLink(isActive:Binding<Bool>) -> some View {
        if #available(iOS 15.0, *) {
            return  AnyView(
                NavigationLink(destination:self,
                               isActive: isActive) {
                                   EmptyView()
                               }.frame(width: 0, height: 0)
                    .hidden())
        } else {
            
            return  AnyView(
                ZStack {
                    NavigationLink(destination:self,
                                   isActive: isActive) {
                        EmptyView()
                    }.frame(width: 0, height: 0)
                        .hidden()
                    
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                })
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) }
        else { self }
    }
}



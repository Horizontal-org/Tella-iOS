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
    
    func navigateTo<Destination: View>( destination: Destination, title: String? = nil, largeTitle:Bool = false) {
        let hostingView = UIHostingController(rootView: destination)
        if largeTitle {
            hostingView.navigationItem.largeTitleDisplayMode = .always
        } else {
            hostingView.navigationItem.largeTitleDisplayMode = .never
        }
        if let title {
            hostingView.title = title
        } else {
            hostingView.title = ""
            
        }
        
        UIApplication.shared.topNavigationController()?.pushViewController(hostingView, animated: true)
    }
    
    @ViewBuilder
    func addNavigationLink<Destination: View>(isActive:Binding<Bool>, shouldAddEmptyView: Bool = false, destination: Destination) -> some View    {
        
        if #available(iOS 16.0, *) {
            
            self.navigationDestination(isPresented: isActive) {
                destination
            }
        } else
        if #available(iOS 15.0, *) {
            ZStack {
                self
                AnyView(
                    NavigationLink(destination:destination,
                                   isActive: isActive) {
                                       EmptyView()
                                   }.frame(width: 0, height: 0)
                        .hidden())
            }
            
        } else {
            ZStack {
                self
                AnyView(
                    ZStack {
                        NavigationLink(destination:destination,
                                       isActive: isActive) {
                            EmptyView()
                        }.frame(width: 0, height: 0)
                            .hidden()
                        
                        if shouldAddEmptyView {
                            NavigationLink(destination: EmptyView()) {
                                EmptyView()
                            }
                        }
                    })
            }
        }
    }
    
    func popToRoot()  {
        UIApplication.shared.popToRootView()
    }
    
    func popTo(_ classType: AnyClass)  {
        UIApplication.shared.popTo(classType)
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

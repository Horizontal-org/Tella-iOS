//
//  ViewExtension.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI
import UIKit

enum ViewPresentationType {
    case push
    case present
}

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
    
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: builder())
        toPresent.modalPresentationStyle = style
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.view.isOpaque = false
        toPresent.view.backgroundColor = .clear
        
        UIApplication.getTopViewController()?.present(toPresent, animated: true, completion: nil)
    }
    
    func dismiss() {
        UIApplication.getTopViewController()?.dismiss(animated: false)
    }
    
    func dismiss(completion:@escaping () -> Void) {
        UIApplication.getTopViewController()?.dismiss(animated: false, completion: completion)
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
    
    func popToRoot(animated:Bool = true)  {
        UIApplication.shared.popToRootView(animated: animated)
    }
    
    func popTo(_ classType: AnyClass)  {
        UIApplication.shared.popTo(classType)
    }
    
    func navigationHasClassType(_ classType: AnyClass) -> Bool {
        UIApplication.shared.navigationHasClassType(classType)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) }
        else { self }
    }
    
    func showTopSheetView<Content:View>( content : Content) {
        let viewToShow = TopSheetView(content:content)
        self.present(style: .overCurrentContext, transitionStyle: .crossDissolve, builder: {viewToShow})
    }
    
    func showBottomSheetView<Content:View>(content : Content, isPresented: Binding<Bool> = .constant(true),
                                           tapToDismiss: Bool = true) {
        let viewToShow = DragView(isPresented: isPresented,
                                  presentationType: .present,
                                  backgroundColor: Styles.Colors.backgroundTab,
                                  tapToDismiss: tapToDismiss,
                                  content: {content})
        self.present(style: .overCurrentContext, transitionStyle: .crossDissolve, builder: {viewToShow})
    }
}


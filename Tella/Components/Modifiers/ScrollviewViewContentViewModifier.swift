//
//  ScrollviewViewContentViewModifier.swift
//  Tella
//
//  Created by RIMA on 16/9/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ScrollviewViewContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    var axis:Axis.Set = .vertical
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
            .background(
                GeometryReader { contentGeometry in
                    Color.clear.onAppear {
                        if axis == .vertical {
                            contentOverflow = contentGeometry.size.height > geometry.size.height
                        } else  {
                            contentOverflow = contentGeometry.size.width > geometry.size.width
                        }
                    }
                }
            )
            .wrappedInScrollView(when: contentOverflow,axis:axis)
        }
    }
}

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool, axis:Axis.Set) -> some View {
        if condition {
            ScrollView(axis) {
                self
            }
        } else {
            self
        }
    }
}

extension View {
    func scrollOnOverflow(axis:Axis.Set = .vertical) -> some View {
        modifier(ScrollviewViewContentViewModifier(axis: axis))
    }
}

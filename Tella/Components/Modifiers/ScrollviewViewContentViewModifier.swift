//
//  ScrollviewViewContentViewModifier.swift
//  Tella
//
//  Created by RIMA on 16/9/2024.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ScrollviewViewContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    var axis: Axis.Set = .vertical
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear
                            .onChange(of: contentGeometry.size) { newContentSize in
                                updateOverflow(containerSize: geometry.size, contentSize: newContentSize)
                            }
                            .onAppear {
                                updateOverflow(containerSize: geometry.size, contentSize: contentGeometry.size)
                            }
                    }
                )
                .wrappedInScrollView(when: contentOverflow, axis: axis)
        }
    }
    
    private func updateOverflow(containerSize: CGSize, contentSize: CGSize) {
        if axis == .vertical {
            contentOverflow = contentSize.height > containerSize.height
        } else {
            contentOverflow = contentSize.width > containerSize.width
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

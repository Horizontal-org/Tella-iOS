//
//  ControlledPager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

enum SwipeDirection { case left, right } // left = forward, right = back

struct ControlledPager<Content: View>: View {
    let pageCount: Int
    @Binding var index: Int
    let canSwipe: (_ fromIndex: Int, _ direction: SwipeDirection) -> Bool
    @ViewBuilder let content: (_ index: Int) -> Content
    
    @State private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width)
            
            HStack(spacing: 0) {
                ForEach(0..<pageCount, id: \.self) { i in
                    content(i)
                        .frame(width: width)
                }
            }
            .offset(x: -CGFloat(index) * width + dragOffset)
            .contentShape(Rectangle())
            .gesture(dragGesture(width: width))
        }
    }
    
    private var dragOffset: CGFloat {
        guard translation != 0 else { return 0 }
        let dir: SwipeDirection = translation < 0 ? .left : .right
        return canSwipe(index, dir) ? translation : 0
    }
    
    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let dir: SwipeDirection = value.translation.width < 0 ? .left : .right
                guard canSwipe(index, dir) else { return }
                translation = value.translation.width
            }
            .onEnded { value in
                let dir: SwipeDirection = value.translation.width < 0 ? .left : .right
                let threshold = width * 0.25
                let projected = value.predictedEndTranslation.width
                var newIndex = index
                
                if canSwipe(index, dir) {
                    if min(value.translation.width, projected) < -threshold, index < pageCount - 1 {
                        newIndex += 1
                    } else if max(value.translation.width, projected) > threshold, index > 0 {
                        newIndex -= 1
                    }
                }
                
                withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2)) {
                    index = min(max(newIndex, 0), pageCount - 1)
                    translation = 0
                }
                index = min(max(newIndex, 0), pageCount - 1)
            }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var index = 0
        
        var body: some View {
            ControlledPager(pageCount: 3, index: $index, canSwipe: { _, _ in true }) { i in
                Text("Page \(i + 1)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
            }
            .background(Styles.Colors.backgroundMain)
        }
    }
    
    return PreviewWrapper()
}

//
//  CustomThumbnailSlider.swift
//  Tella
//
//  Created by RIMA on 15.11.24.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CustomThumbnailSlider: View {
    
    //MARK: - Private Attributes
    @State private var isEditing = false
    private let kOffset = 3.0
    
    @Binding var value: CGFloat
    var range: ClosedRange<Double>
    
    var sliderHeight = 200.0
    var sliderWidth = 10.0
    var sliderImage: String
    
    var onEditingChanged: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            sliderImage(in: geometry)
                .gesture(dragGesture(in: geometry))
        }
    }
    
    // Extract slider image view with offset calculation
    private func sliderImage(in geometry: GeometryProxy) -> some View {
        ResizableImage(sliderImage)
            .frame(width: sliderWidth)
            .offset(x: calculateThumbOffset(in: geometry), y: 0)
    }
    
    // Drag gesture with adjusted conditions for limit scrolling
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                let newValue = Double(dragValue.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                value = min(max(newValue, range.lowerBound), range.upperBound)
                
                onEditingChanged?()
            }
    }
    // Calculate the offset for the thumb
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kOffset
    }
}

//
//  TrimAudioSliderView.swift
//  Tella
//
//  Created by RIMA on 30.10.24.
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TrimMediaSliderView: View {
    @Binding var currentValue: Double
    @Binding var gestureValue: Double
    @Binding var isDragging: Bool
    
    var range: ClosedRange<Double>
    var currentRange: ClosedRange<Double>
    var editMedia: EditMediaProtocol
    var sliderType: SliderType
    
    private let minimumSliderDistance: CGFloat = 45.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                sliderImage(in: geometry)
                    .gesture(dragGesture(in: geometry))
                
                valueLabel(in: geometry)
            }
        }
    }
    
    // MARK: - Slider Image
    private func sliderImage(in geometry: GeometryProxy) -> some View {
        let imageName = (sliderType == .leading)
        ? editMedia.leadingImageName
        : editMedia.trailingImageName
        
        return Image(imageName)
            .offset(x: calculateThumbOffset(in: geometry))
    }
    
    // MARK: - Value Label
    private func valueLabel(in geometry: GeometryProxy) -> some View {
        Text(TimeInterval(currentValue).formattedAsMMSS())
            .foregroundColor(Styles.Colors.yellow)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .offset(
                x: calculateLabelOffset(in: geometry),
                y: (geometry.size.height / 2) + 15
            )
    }
    
    // MARK: - Drag Gesture
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                isDragging = true
                let limitedX = drag.location.x.clamped(to: 0...geometry.size.width)
                let newValue = offsetToValue(limitedX, in: geometry)
                let clampedValue = newValue.clamped(to: range)
                
                guard isDragAllowed(newValue: clampedValue, in: geometry) else { return }
                
                currentValue = clampedValue
                gestureValue = calculateThumbOffset(in: geometry)
            }
            .onEnded { _ in
                gestureValue = calculateThumbOffset(in: geometry)
                isDragging = false
            }
    }
    
    // MARK: - Coordinate Conversion
    private func offsetToValue(_ offset: CGFloat, in geometry: GeometryProxy) -> Double {
        let percentage = offset / geometry.size.width
        return range.lowerBound + percentage * (range.upperBound - range.lowerBound)
    }
    
    private func valueToOffset(_ value: Double, in geometry: GeometryProxy) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
    }
    
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let offset = valueToOffset(currentValue, in: geometry)
        let thumbAdjustment = (sliderType == .leading) ? 0 : -editMedia.sliderWidth
        return offset + CGFloat(thumbAdjustment)
    }
    
    private func calculateLabelOffset(in geometry: GeometryProxy) -> CGFloat {
        let labelPadding = (sliderType == .leading)
        ? editMedia.leadingLabelPadding
        : editMedia.trailingLabelPadding
        
        return valueToOffset(currentValue, in: geometry) + CGFloat(labelPadding)
    }
    
    // MARK: - Drag Validation
    private func isDragAllowed(newValue: Double, in geometry: GeometryProxy) -> Bool {
        let currentOffset = valueToOffset(newValue, in: geometry)
        
        let referenceValue = (sliderType == .leading)
        ? currentRange.upperBound
        : currentRange.lowerBound
        
        let referenceOffset = valueToOffset(referenceValue, in: geometry)
        
        return abs(currentOffset - referenceOffset) >= minimumSliderDistance
    }
}

// MARK: - Utility Extensions
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

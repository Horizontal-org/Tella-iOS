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
    var range: ClosedRange<Double>
    var currentRange: ClosedRange<Double>
    var editMedia: EditMediaProtocol
    var sliderType: SliderType
    
    @Binding var gestureValue: Double
    @Binding var isDragging : Bool
    
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
    
    private func sliderImage(in geometry: GeometryProxy) -> some View {
        let imageName = sliderType == .leading ? editMedia.leadingImageName : editMedia.trailingImageName
        return Image(imageName)
            .offset(x: calculateThumbOffset(in: geometry), y: 0)
    }
    
    private func valueLabel(in geometry: GeometryProxy) -> some View {
        Text("\(TimeInterval(currentValue).formattedAsMMSS())")
            .foregroundColor(Styles.Colors.yellow)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .offset(x: calculateLabelOffset(in: geometry), y: (geometry.size.height / 2) + 15)
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                isDragging = true
                let xPosition = min(max(0, dragValue.location.x), geometry.size.width)
                let newValue = convertOffsetToValue(xPosition, in: geometry)
                
                let proposedValue = min(max(newValue, range.lowerBound), range.upperBound)
                
                guard isDragAllowed(in: geometry, newValue: proposedValue) else { return }
                
                currentValue = proposedValue
                gestureValue = calculateThumbOffset(in: geometry)
            }
            .onEnded { _ in
                gestureValue = calculateThumbOffset(in: geometry)
                isDragging = false
            }
    }
    
    private func convertOffsetToValue(_ offset: CGFloat, in geometry: GeometryProxy) -> Double {
        let percentage = offset / geometry.size.width
        return range.lowerBound + percentage * (range.upperBound - range.lowerBound)
    }
    
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let additionalOffset = sliderType == .leading ? 0 : -editMedia.sliderWidth
        let offset =  convert(value: currentValue, in: geometry)
        return offset + CGFloat(additionalOffset)
    }
    
    private func isDragAllowed(in geometry: GeometryProxy, newValue:CGFloat) -> Bool  {
        
        let currentOffset = convert(value: newValue, in: geometry)
        
        let valueeee = sliderType == .leading ? currentRange.upperBound : currentRange.lowerBound
        let otherOffset = convert(value: valueeee, in: geometry)
        
        let distance = abs(currentOffset - otherOffset)
        
        return distance >= minimumSliderDistance
    }
    
    private func calculateLabelOffset(in geometry: GeometryProxy) -> CGFloat {
        let additionalOffset = sliderType == .leading ? editMedia.leadingLabelPadding : editMedia.trailingLabelPadding
        let offset =  convert(value: currentValue, in: geometry)
        return offset + CGFloat(additionalOffset)
    }
    
    func convert(value:CGFloat , in geometry: GeometryProxy) -> CGFloat {
        return CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
    }
}

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
    @Binding var value: Double
    var range: ClosedRange<Double>
    var currentRange: ClosedRange<Double>
    var editMedia: EditMediaProtocol
    var sliderType: SliderType 
    
    @Binding var gestureValue: Double
    @Binding var isDragging : Bool
    
    private let minimumAudioDuration = 3.0
    
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
        Text("\(TimeInterval(value).formattedAsMMSS())")
            .foregroundColor(Styles.Colors.yellow)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .offset(x: calculateLabelOffset(in: geometry), y: (geometry.size.height / 2) + 15)
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                isDragging = true
                let clampedX = min(max(0, dragValue.location.x), geometry.size.width)
                let newValue = (clampedX / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                
                
                if sliderType == .trailing {
                    guard newValue >= currentRange.lowerBound + minimumAudioDuration else { return }

                } else {
                  guard newValue + minimumAudioDuration <= currentRange.upperBound else { return }
                }

                value = min(max(newValue, range.lowerBound), range.upperBound)
                gestureValue = calculateThumbOffset(in: geometry)
            }
            .onEnded { _ in
                gestureValue = calculateThumbOffset(in: geometry)
                isDragging = false
            }
    }
    
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        
        let additionalOffset = sliderType == .leading ? 0 : -editMedia.sliderWidth
        let offset = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
        return offset + CGFloat(additionalOffset)
    }
    
    private func calculateLabelOffset(in geometry: GeometryProxy) -> CGFloat {
        let additionalOffset = sliderType == .leading ? editMedia.leadingLabelPadding : editMedia.trailingLabelPadding
        let offset = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
        return offset + CGFloat(additionalOffset)
    }
}

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
    var editMedia: EditMediaProtocol
    var sliderType: SliderType //This variable to check if the slider starts from the left or the right side
    
    @Binding var gestureValue: Double
    @Binding var shouldLimitScrolling: Bool
    @Binding var isDragging : Bool
    
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
                
                if shouldLimitScrolling {
                    
                    if sliderType == .trailing {
                        guard newValue >= value else { return }
                    } else {
                        guard newValue <= value else { return }
                    }
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

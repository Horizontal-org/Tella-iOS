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
    @Binding var gestureValue: Double
    @Binding var shouldLimitScrolling: Bool
    var sliderHeight = 200.0
    @State var isRightSlider: Bool //This variable to check if the slider starts from the left or the right side
    private let kOffset = 3.0 //This is added to adjust the difference of the elipse in the trim line image
    private let kLabelOffset = 15.0 //This constant is added to center the value label in the trim line
    
    var sliderImage: String
    var imageWidth = 18.0
    
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
        ResizableImage(sliderImage)
            .frame(width: imageWidth, height: sliderHeight)
            .offset(x: calculateThumbOffset(in: geometry), y: 0)
    }
    
    private func valueLabel(in geometry: GeometryProxy) -> some View {
        Text("\(TimeInterval(value).formattedAsMMSS())")
            .foregroundColor(Styles.Colors.yellow)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .offset(x: calculateLabelOffset(in: geometry), y: (sliderHeight / 2) + 15)
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                isDragging = true
                let clampedX = min(max(0, dragValue.location.x), geometry.size.width)
                let newValue = (clampedX / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound

                if shouldLimitScrolling {
                    if isRightSlider {
                        guard newValue >= value else { return }
                    } else {
                        guard newValue <= value else { return }
                    }
                }

                value = min(max(newValue, range.lowerBound), range.upperBound)
            }
            .onEnded { dragValue in
                gestureValue = calculateThumbOffset(in: geometry)
                isDragging = false
            }
    }
    
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let additionalOffset = isRightSlider ? -18 : 0
        let offset = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
        return offset + CGFloat(additionalOffset)
    }

    private func calculateLabelOffset(in geometry: GeometryProxy) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kLabelOffset
    }
}

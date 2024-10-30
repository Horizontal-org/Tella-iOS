//
//  TrimAudioSliderView.swift
//  Tella
//
//  Created by RIMA on 30.10.24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TrimAudioSliderView: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    @Binding var gestureValue: Double
    @Binding var shouldLimitScrolling: Bool
    
    @State private var isRightSlider = false //This variable to check if the slider starts from the left or the right side
    private let kOffset = 3.0 //This is added to adjust the difference of the elipse in the trim line image
    private let kLabelOffset = 15.0 //This constant is added to center the value label in the trim line
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                sliderImage(in: geometry)
                    .gesture(dragGesture(in: geometry))
                valueLabel(in: geometry)
            }
        }
        .onAppear {
            isRightSlider = range.upperBound == value
        }
    }
    
    // Extract slider image view with offset calculation
    private func sliderImage(in geometry: GeometryProxy) -> some View {
        Image("edit.audio.trim.line")
            .resizable()
            .frame(width: 10, height: 200)
            .offset(x: calculateThumbOffset(in: geometry), y: -10)
    }
    
    // Extract value label with offset calculation
    private func valueLabel(in geometry: GeometryProxy) -> some View {
        Text("\(TimeInterval(value).formattedAsMMSS())")
            .foregroundColor(Styles.Colors.yellow)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .offset(x: calculateLabelOffset(in: geometry), y: 105)
    }
    
    // Drag gesture with adjusted conditions for limit scrolling
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                let newValue = Double(dragValue.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                gestureValue = calculateThumbOffset(in: geometry)
                
                if shouldLimitScrolling {
                    if isRightSlider {
                        guard newValue >= value else { return }
                    } else {
                        guard newValue <= value else { return }
                    }
                }
                
                value = min(max(newValue, range.lowerBound), range.upperBound)
            }
            .onEnded { _ in
                gestureValue = calculateThumbOffset(in: geometry)
            }
    }
    
    // Calculate the offset for the thumb
    private func calculateThumbOffset(in geometry: GeometryProxy) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kOffset
    }
    
    // Calculate the offset for the value label
    private func calculateLabelOffset(in geometry: GeometryProxy) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - kLabelOffset
    }
    // Calculate the offset
    private func calculateOffset(in geometry: GeometryProxy, with constant: CGFloat) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - constant
    }
}

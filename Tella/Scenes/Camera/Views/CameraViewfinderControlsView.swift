//
//  CameraViewfinderControlsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraViewfinderControlsView: View {
    
    let zoomLevels: [CameraZoomLevel]
    let zoomFactor: CGFloat
    /// Set only while a video is being recorded.
    let recordingTime: String?
    var rotation = CameraControlRotation()
    let onSelectZoomLevel: (CameraZoomLevel) -> Void
    let onMoreOptions: () -> Void
    
    var body: some View {
        VStack(spacing: .normal) {
            // recordingIndicator
            controlsRow
        }.frame(height: 52.adjusted)
        
    }
    
    @ViewBuilder
    private var recordingIndicator: some View {
        if let recordingTime = recordingTime {
            CustomText(recordingTime, style: .cameraTabStyle)
                .padding(.horizontal, .small)
                .padding(.vertical, .tiny)
                .background(Capsule().fill(Styles.Colors.darkRed))
                .rotate(rotation)
                .transition(.opacity)
        }
    }
    
    private var controlsRow: some View {
        ZStack {
            zoomLevelsView
            
            HStack {
                Spacer()
                    .allowsHitTesting(false)
                moreOptionsButton
            }
            .padding(.trailing, .medium)
        }
    }
    
    /// Hidden when the lens set only reaches a single level, as with most front cameras.
    @ViewBuilder
    private var zoomLevelsView: some View {
        if zoomLevels.count > 1 {
            HStack(spacing: 0) {
                ForEach(zoomLevels) { level in
                    Button {
                        onSelectZoomLevel(level)
                    } label: {
                        zoomLevelPill(for: level)
                            .padding(.all, .tiny)
                    }
                }
            }
        }
    }
    
    private var activeZoomLevel: CameraZoomLevel? {
        CameraZoomLevel.active(for: zoomFactor, in: zoomLevels)
    }
    
    private func zoomLevelPill(for level: CameraZoomLevel) -> some View {
        let isActive = level == activeZoomLevel
        
        return CustomText(isActive ? CameraZoomLevel.activeTitle(for: zoomFactor) : level.title,
                          style: .subheading2Style,
                          alignment: .center,
                          color: isActive ? Styles.Colors.backgroundGrey1 : .white)
        .rotate(rotation)
        .frame(width: .smallMediumIconSize, height: .smallMediumIconSize)
        .background(Capsule().fill(isActive ? Styles.Colors.grey1
                                   : Styles.Colors.backgroundGrey2))
    }
    
    private var moreOptionsButton: some View {
        Button(action: onMoreOptions) {
            Image(.cameraMoreGrid)
                .frame(width: .smallMediumIconSize, height: .smallMediumIconSize)
                .background(Circle().fill(Styles.Colors.backgroundGrey2))
                .padding(.all, .tiny)
        }
        .rotate(rotation)
    }
}

struct CameraViewfinderControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            CameraViewfinderControlsView(zoomLevels: [CameraZoomLevel(factor: 0.5),
                                                      CameraZoomLevel(factor: 1),
                                                      CameraZoomLevel(factor: 2)],
                                         zoomFactor: 1,
                                         recordingTime: "00:00:12",
                                         onSelectZoomLevel: { _ in },
                                         onMoreOptions: {})
        }
        .background(Color.gray)
    }
}

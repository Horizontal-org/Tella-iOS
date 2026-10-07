//
//  CameraPreviewControlsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraPreviewControlsView: View {
    
    let zoomLevels: [CameraZoomLevel]
    let zoomFactor: CGFloat
    let isRecording: Bool
    var rotation = CameraControlRotation()
    let onSelectZoomLevel: (CameraZoomLevel) -> Void
    let onMoreOptions: () -> Void
    
    var body: some View {
        controlsRow
            .frame(height: CameraViewfinderLayout.zoomHeight)
    }
    
    private var controlsRow: some View {
        ZStack {
            zoomLevelsView
            
            HStack {
                Spacer()
                    .allowsHitTesting(false)
                if !isRecording {
                    moreOptionsButton
                }
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
                            .frame(width: .mediumIconSize,
                                   height: .mediumIconSize)
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
        .frame(width: .smallIconSize, height: .smallIconSize)
        .background(Capsule().fill(isActive ? Styles.Colors.grey1
                                   : Styles.Colors.backgroundGrey2))
    }
    
    private var moreOptionsButton: some View {
        Button(action: onMoreOptions) {
            Image(.cameraMoreGrid)
                .frame(width: .smallIconSize, height: .smallIconSize)
                .background(Circle().fill(Styles.Colors.backgroundGrey2))
                .frame(width: .mediumIconSize,
                       height: .mediumIconSize)
            
        }
        .rotate(rotation)
    }
}

struct CameraPreviewControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            CameraPreviewControlsView(zoomLevels: [CameraZoomLevel(factor: 0.5),
                                                   CameraZoomLevel(factor: 1),
                                                   CameraZoomLevel(factor: 2)],
                                      zoomFactor: 1,
                                      isRecording: false,
                                      onSelectZoomLevel: { _ in },
                                      onMoreOptions: {})
        }
        .background(Color.gray)
    }
}

//
//  CameraPreviewControlsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

/// Positions zoom and extra options over the camera preview.
struct CameraPreviewControlsView: View {
    // MARK: - Public properties
    
    let zoomLevels: [CameraZoomLevel]
    let zoomLenses: [CameraZoomLens]
    let zoomFactor: CGFloat
    let zoomRange: ClosedRange<CGFloat>
    let zoomFrame: CGRect
    let dialFrame: CGRect
    let interactionFrame: CGRect
    @Binding var isZoomDialExpanded: Bool
    let isRecording: Bool
    var isFlipping: Bool = false
    var rotation = CameraControlRotation()
    let onZoomChanged: (CGFloat) -> Void
    let onSelectZoomLevel: (CameraZoomLevel) -> Void
    let onMoreOptions: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if !isRecording && !isZoomDialExpanded {
                moreOptionsButton
                    .position(x: zoomFrame.maxX - .medium - .mediumIconSize / 2,
                              y: zoomFrame.midY)
            }
            
            CameraZoomTouchControl(zoomLevels: zoomLevels,
                                   zoomLenses: zoomLenses,
                                   zoomFactor: zoomFactor,
                                   zoomRange: zoomRange,
                                   zoomFrame: zoomFrame,
                                   dialFrame: dialFrame,
                                   interactionFrame: interactionFrame,
                                   isExpanded: $isZoomDialExpanded,
                                   rotation: rotation,
                                   onZoomChanged: onZoomChanged,
                                   onSelectZoomLevel: onSelectZoomLevel)
            .opacity(isFlipping ? 0 : 1)
        }
    }
    
    // MARK: - More options
    
    private var moreOptionsButton: some View {
        Button(action: onMoreOptions) {
            Image(.cameraMoreGrid)
                .frame(width: .smallIconSize, height: .smallIconSize)
                .background(Circle().fill(Styles.Colors.backgroundGrey2))
                .frame(width: .mediumIconSize, height: .mediumIconSize)
        }
        .rotate(rotation)
    }
}

// MARK: - Previews

struct CameraPreviewControlsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CameraPreviewControlsView(zoomLevels: levels,
                                      zoomLenses: lenses,
                                      zoomFactor: 1,
                                      zoomRange: 0.5...5,
                                      zoomFrame: zoomFrame,
                                      dialFrame: zoomFrame,
                                      interactionFrame: interactionFrame,
                                      isZoomDialExpanded: .constant(false),
                                      isRecording: false,
                                      onZoomChanged: { _ in },
                                      onSelectZoomLevel: { _ in }, onMoreOptions: {})
            .previewDisplayName("Presets")
            
            CameraZoomTouchControl(zoomLevels: levels,
                                   zoomLenses: lenses,
                                   zoomFactor: 1,
                                   zoomRange: 0.5...5,
                                   zoomFrame: zoomFrame,
                                   dialFrame: zoomFrame,
                                   interactionFrame: interactionFrame,
                                   isExpanded: .constant(true),
                                   rotation: CameraControlRotation(deviceOrientation: .portrait),
                                   onZoomChanged: { _ in },
                                   onSelectZoomLevel: { _ in })
            .background {
                CameraZoomDialBackground(zoomFrame: zoomFrame,
                                         bottomEdge: zoomFrame.maxY + CameraViewfinderLayout.shutterHeight)
            }
            .previewDisplayName("Dial")
        }
        .frame(width: 390, height: 600)
        .background(Color.gray)
    }
    
    private static let levels = [0.5, 1, 2].map { CameraZoomLevel(factor: $0) }
    private static let lenses = [CameraZoomLens(factor: 0.5, focalLength: 13),
                                 CameraZoomLens(factor: 1, focalLength: 26)]
    private static let zoomFrame = CGRect(x: 0, y: 400, width: 390, height: 52)
    private static let interactionFrame = CGRect(x: 0, y: 56, width: 390, height: 396)
}

//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession
    let gridIsOn: Bool
    var onZoomBegan: (() -> Void)? = nil
    var onZoomChanged: ((CGFloat) -> Void)? = nil
    var onSwipe: ((CameraSwipeDirection) -> Void)? = nil
    var onTap: (() -> Void)? = nil
    
    final class VideoPreviewView: UIView {
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        private var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
        
        let gridOverlay = CameraGridOverlayView()
        
        var onZoomBegan: (() -> Void)?
        var onZoomChanged: ((CGFloat) -> Void)?
        var onSwipe: ((CameraSwipeDirection) -> Void)?
        var onTap: (() -> Void)?
        
        private let pinchGesture = UIPinchGestureRecognizer()
        private let tapGesture = UITapGestureRecognizer()
        private let panGesture = UIPanGestureRecognizer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = Styles.uiColor.backgroundGrey1
            clipsToBounds = true
            previewLayer.videoGravity = .resizeAspectFill
            addSubview(gridOverlay)
            
            pinchGesture.addTarget(self, action: #selector(handlePinch))
            addGestureRecognizer(pinchGesture)
            
            tapGesture.addTarget(self, action: #selector(handleTap))
            addGestureRecognizer(tapGesture)
            
            panGesture.addTarget(self, action: #selector(handlePan))
            panGesture.maximumNumberOfTouches = 1
            addGestureRecognizer(panGesture)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configurePreview(session: AVCaptureSession) {
            if previewLayer.session !== session {
                previewLayer.session = session
            }
            updatePreviewOrientation()
        }
        
        func updateGestureAvailability() {
            setEnabled(isUserInteractionEnabled && (onZoomBegan != nil || onZoomChanged != nil),
                       for: pinchGesture)
            let isPinching = pinchGesture.state == .began || pinchGesture.state == .changed
            setEnabled(isUserInteractionEnabled && onSwipe != nil && !isPinching, for: panGesture)
            setEnabled(isUserInteractionEnabled && onTap != nil, for: tapGesture)
        }
        
        func dismantlePreview() {
            onZoomBegan = nil
            onZoomChanged = nil
            onSwipe = nil
            onTap = nil
            isUserInteractionEnabled = false
            updateGestureAvailability()
            previewLayer.session = nil
        }
        
        private func setEnabled(_ isEnabled: Bool, for gesture: UIGestureRecognizer) {
            guard gesture.isEnabled != isEnabled else { return }
            gesture.isEnabled = isEnabled
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            gridOverlay.frame = bounds
            updatePreviewOrientation()
        }
        
        private func updatePreviewOrientation() {
            guard let connection = previewLayer.connection,
                  connection.isVideoOrientationSupported,
                  connection.videoOrientation != .portrait else { return }
            connection.videoOrientation = .portrait
        }
        
        @objc private func handleTap() {
            onTap?()
        }
        
        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                setEnabled(false, for: panGesture)
                onZoomBegan?()
            case .changed:
                onZoomChanged?(gesture.scale)
            case .ended, .cancelled, .failed:
                setEnabled(isUserInteractionEnabled && onSwipe != nil, for: panGesture)
            default:
                break
            }
        }
        
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard gesture.state == .ended else { return }
            
            let translation = gesture.translation(in: self)
            guard let direction = CameraSwipeDirection(translationX: translation.x,
                                                       translationY: translation.y) else { return }
            onSwipe?(direction)
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        updatePreview(view, isEnabled: context.environment.isEnabled)
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        updatePreview(uiView, isEnabled: context.environment.isEnabled)
    }
    
    static func dismantleUIView(_ uiView: VideoPreviewView, coordinator: Coordinator) {
        uiView.dismantlePreview()
    }
    
    private func updatePreview(_ view: VideoPreviewView, isEnabled: Bool) {
        view.isUserInteractionEnabled = isEnabled
        view.configurePreview(session: session)
        view.gridOverlay.isHidden = !gridIsOn
        view.onZoomBegan = onZoomBegan
        view.onZoomChanged = onZoomChanged
        view.onSwipe = onSwipe
        view.onTap = onTap
        view.updateGestureAvailability()
    }
}

struct CameraPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(aspectRatio: .threeByFour, gridIsOn: false)
                .previewDisplayName("3:4 - Grid off")
            preview(aspectRatio: .threeByFour, gridIsOn: true)
                .previewDisplayName("3:4 - Grid on")
        }
    }
    
    private static func preview(aspectRatio: CameraAspectRatio, gridIsOn: Bool) -> some View {
        CameraPreview(session: AVCaptureSession(), gridIsOn: gridIsOn)
            .frame(width: 300, height: 300 / aspectRatio.widthOverHeight)
            .previewLayout(.sizeThatFits)
    }
}

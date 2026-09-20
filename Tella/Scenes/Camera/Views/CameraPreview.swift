//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    private static let swipeThreshold: CGFloat = 40
    
    let session: AVCaptureSession
    let gridIsOn: Bool
    var onZoomBegan: (() -> Void)? = nil
    var onZoomChanged: ((CGFloat) -> Void)? = nil
    var onSwipe: ((CameraSwipeDirection) -> Void)? = nil
    
    class VideoPreviewView: UIView {
        
        let gridOverlay = CameraGridOverlayView()
        
        var onZoomBegan: (() -> Void)?
        var onZoomChanged: ((CGFloat) -> Void)?
        var onSwipe: ((CameraSwipeDirection) -> Void)?
        
        private let panGesture = UIPanGestureRecognizer()
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(gridOverlay)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
            addGestureRecognizer(pinchGesture)
            
            panGesture.addTarget(self, action: #selector(handlePan))
            panGesture.maximumNumberOfTouches = 1
            addGestureRecognizer(panGesture)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configurePreview(session: AVCaptureSession) {
            backgroundColor = .black
            videoPreviewLayer.cornerRadius = 0
            videoPreviewLayer.session = session
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let videoRect = videoPreviewLayer.layerRectConverted(
                fromMetadataOutputRect: CGRect(x: 0, y: 0, width: 1, height: 1)
            )
            gridOverlay.frame = videoRect.intersection(bounds)
        }
        
        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                panGesture.isEnabled = false
                onZoomBegan?()
            case .changed:
                onZoomChanged?(gesture.scale)
            case .ended, .cancelled, .failed:
                panGesture.isEnabled = true
            default:
                break
            }
        }
        
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard gesture.state == .ended else { return }
            
            let translation = gesture.translation(in: self)
            guard abs(translation.x) > CameraPreview.swipeThreshold,
                  abs(translation.x) > abs(translation.y) else { return }
            
            onSwipe?(translation.x < 0 ? .left : .right)
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.configurePreview(session: session)
        view.gridOverlay.isHidden = !gridIsOn
        updateCallbacks(on: view)
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        uiView.gridOverlay.isHidden = !gridIsOn
        uiView.setNeedsLayout()
        updateCallbacks(on: uiView)
    }
    
    private func updateCallbacks(on view: VideoPreviewView) {
        view.onZoomBegan = onZoomBegan
        view.onZoomChanged = onZoomChanged
        view.onSwipe = onSwipe
    }
}

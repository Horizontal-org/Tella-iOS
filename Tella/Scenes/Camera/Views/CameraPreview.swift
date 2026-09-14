//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession
    let gridIsOn: Bool
    var onZoomBegan: (() -> Void)? = nil
    var onZoomChanged: ((CGFloat) -> Void)? = nil
    
    class VideoPreviewView: UIView {
        
        let gridOverlay = CameraGridOverlayView()
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
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
    }
    
    class Coordinator: NSObject {
        var parent: CameraPreview
        
        init(_ parent: CameraPreview) {
            self.parent = parent
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                parent.onZoomBegan?()
            case .changed:
                parent.onZoomChanged?(gesture.scale)
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.configurePreview(session: session)
        view.gridOverlay.isHidden = !gridIsOn
        view.addSubview(view.gridOverlay)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator,
                                                    action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        uiView.gridOverlay.isHidden = !gridIsOn
        uiView.setNeedsLayout()
        context.coordinator.parent = self
    }
}

//
//  QRCodeScannerView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/2/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import AVFoundation
import SwiftUI

struct QRCodeScannerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var scannedCode: String?
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               metadataObject.type == .qr,
               let scannedValue = metadataObject.stringValue {
                DispatchQueue.main.async {
                    self.parent.scannedCode = scannedValue
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return UIViewController()
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return UIViewController()
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        
        let scannerView = ScannerView()
        scannerView.previewLayer.session = captureSession
        scannerView.previewLayer.videoGravity = .resizeAspectFill
        
        let viewController = UIViewController()
        viewController.view.addSubview(scannerView)
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scannerView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            scannerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class ScannerView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

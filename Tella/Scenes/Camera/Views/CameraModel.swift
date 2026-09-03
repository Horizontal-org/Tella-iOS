//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import AVFoundation
import Combine
import UIKit

final class CameraModel: ObservableObject {
    
    let service : CameraService = CameraService()
    
    @Published var imageCompletion: (CameraImageCompletion)?
    @Published var videoURLCompletion: URL?
    @Published var shouldShowPermission = false
    @Published var isRecording = false
    @Published var shouldCloseCamera = false
    @Published var shouldShowProgressView = false
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var flashMode: CameraFlashMode = .off
    @Published var isFlashAvailable = false
    
    var session: AVCaptureSession
    var shouldPreserveMetadata: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.captureSession
        
        service.$imageCompletion.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.imageCompletion = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowPermission.sink { [weak self] (val) in
            self?.shouldShowPermission = val
        }
        .store(in: &self.subscriptions)
        
        service.$videoURLCompletion.sink { [weak self] (val) in
            guard let val = val else { return }
            self?.videoURLCompletion = val
        }
        .store(in: &self.subscriptions)
        
        service.$currentZoomFactor.sink { [weak self] (val) in
            self?.currentZoomFactor = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] mode in
            self?.flashMode = mode
        }
        .store(in: &self.subscriptions)
        
        service.$isFlashAvailable.sink { [weak self] isAvailable in
            self?.isFlashAvailable = isAvailable
        }
        .store(in: &self.subscriptions)
    }
    
    var cameraType : CameraType = .image {
        didSet {
            service.cameraType = cameraType
        }
    }
    
    func configure() {
        service.shouldPreserveMetadata = shouldPreserveMetadata
        service.resumeOrSetupCaptureSession()
    }
    
    func capturePhoto() {
        service.takePhoto()
    }
    
    func startCaptureVideo() {
        service.startCaptureVideo()
    }
    
    func toggleCameraType() {
        service.toggleCameraType()
    }
    
    func setFlashMode(_ mode: CameraFlashMode) {
        service.setFlashMode(mode)
    }
    
    func startZoom() {
        service.startZoom()
    }
    
    func zoom(by pinchScale: CGFloat) {
        service.zoom(by: pinchScale)
    }
    
    func stopRunningCaptureSession() {
        service.stopRunningCaptureSession()
    }
}

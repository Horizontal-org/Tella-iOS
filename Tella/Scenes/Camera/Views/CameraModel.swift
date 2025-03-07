//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
    }
    
    var cameraType : CameraType = .image {
        didSet {
            service.cameraType = cameraType
        }
    }
    
    func configure() {
        service.shouldPreserveMetadata = shouldPreserveMetadata
        service.checkCameraPermission()
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
    
    func toggleFlash() {
        service.toggleFlash()
    }
    
    func stopRunningCaptureSession() {
        service.stopRunningCaptureSession()
    }
}

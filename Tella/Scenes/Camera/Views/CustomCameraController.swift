//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import AVFoundation
import Combine
import CoreLocation

struct CameraImageCompletion {
    var capturePhoto: AVCapturePhoto?
    var currentLocation: CLLocation?
}

public class CameraService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Private properties
    
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var  deviceOrientation : UIDeviceOrientation = UIDevice.current.orientation
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var locationManager = LocationManager()
    private let zoomController = CameraZoomController()
    
    var shouldPreserveMetadata: Bool = false
    
    weak private var captureDelegate: AVCapturePhotoCaptureDelegate?
    weak private var videoRecordingDelegate: AVCaptureFileOutputRecordingDelegate?
    
    // MARK: - Public properties
    
    var captureSession = AVCaptureSession()
    
    @Published var shouldShowPermission : Bool = false
    @Published var shouldCloseCamera : Bool = false
    @Published var shouldShowProgressView : Bool = false
    @Published var imageCompletion: CameraImageCompletion?
    @Published var videoURLCompletion: URL?
    @Published var isRecording = false
    @Published var currentZoomFactor: CGFloat = 1.0
    
    var cameraType : CameraType = .image {
        didSet {
            stopRunningCaptureSession()
            releasePreview()
            cameraType == .video ? setupVideoInputOutput() : setupPhotoInputOutput()
        }
    }
    
    var photoSettings : AVCapturePhotoSettings {
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        
        photoSettings.isHighResolutionPhotoEnabled = true
        
        if let currentLocation = locationManager.currentLocation {
            photoSettings.add(location: currentLocation)
        }
        
        return photoSettings
    }
    
    func startRunningCaptureSession() {
        if shouldPreserveMetadata {
            locationManager.startUpdatingLocation()
        }
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    
    func stopRunningCaptureSession() {
        captureSession.stopRunning()
        shouldCloseCamera = false
        locationManager.stopUpdatingLocation()
    }
    
    func takePhoto() {
        
        guard let delegate = captureDelegate else {
            return
        }
        if let photoOutputConnection = self.photoOutput?.connection(with: .video) {
            photoOutputConnection.videoOrientation = deviceOrientation.videoOrientation()
        }
        
        photoOutput?.capturePhoto(with: photoSettings, delegate: delegate)
        shouldShowProgressView = true
    }
    
    func startCaptureVideo() {
        guard let videoOutput = videoOutput else { return }
        
        if videoOutput.isRecording {
            videoOutput.stopRecording()
            shouldShowProgressView = true
            return
        }
        let outFileUrl = createTempFileURL()
        guard let delegate = videoRecordingDelegate else {
            return
        }
        
        if let videoOutputConnection = videoOutput.connection(with: .video) {
            videoOutputConnection.videoOrientation = deviceOrientation.videoOrientation()
        }
        
        if shouldPreserveMetadata, let currentLocation = locationManager.currentLocation {
            // Add location to the video output
            videoOutput.add(location: currentLocation)
        }
        
        videoOutput.startRecording(to: outFileUrl, recordingDelegate: delegate )
    }
    
    func toggleCameraType() {
        guard let inputCameraPosition = inputCameraPosition() else {
            return
        }
        if let currentInput = cameraInput() {
            captureSession.removeInput(currentInput)
        }
        
        switch inputCameraPosition {
        case .back:
            if let  frontCameraInput = cameraDeviceInput(type: .front) {
                self.captureSession.addInput(frontCameraInput)
            }
            
        case .front:
            if let  backCameraInput = cameraDeviceInput(type: .back) {
                self.captureSession.addInput(backCameraInput)
            }
            
        default:
            break
        }
        applyDefaultZoom()
    }
    
    func toggleFlash() {
        
        if let avDevice = inputCamera() {
            
            if avDevice.hasTorch {
                do {
                    try avDevice.lockForConfiguration()
                } catch {
                    
                }
                avDevice.torchMode =  avDevice.torchMode == . on ? .off : .on
                avDevice.unlockForConfiguration()
            }
        }
    }
    
    /// Captures the current zoom factor when a pinch gesture begins
    func startZoom() {
        zoomController.startZoom(device: inputCamera())
    }
    
    func zoom(by pinchScale: CGFloat) {
        guard let device = inputCamera() else { return }
        
        currentZoomFactor = zoomController.zoom(
            by: pinchScale,
            device: device
        )
    }
    
    private func applyDefaultZoom() {
        guard let device = inputCamera() else { return }
        
        currentZoomFactor = zoomController.applyDefaultZoom(
            device: device
        )
    }
    
    // MARK: - Private functions
    
    func setup() {
        
        captureDelegate = self
        videoRecordingDelegate = self
        
        shouldCloseCamera = false
        
        DeviceOrientationHelper().startDeviceOrientationNotifier { deviceOrientation in
            self.deviceOrientation = deviceOrientation
        }
        
        stopRunningCaptureSession()
        releasePreview()
        
        setupCaptureSession()
        
        cameraType == .video ? setupVideoInputOutput() : setupPhotoInputOutput()
    }
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        if cameraType == .video {
            if captureSession.canSetSessionPreset(.high) {
                captureSession.sessionPreset = .high
            }
        } else {
            captureSession.sessionPreset = .photo
        }
        captureSession.commitConfiguration()
    }
    
    private func createTempFileURL() -> URL {
        let pathURL = URL(fileURLWithPath:NSTemporaryDirectory())
        return pathURL.appendingPathComponent("movie-\(Int(Date().timeIntervalSince1970)).\(FileExtension.mov)")
    }
    
    private func setupPhotoInputOutput() {
        // Camera Device Input
        guard let  backCameraInput = cameraDeviceInput(type: .back)  else { return}
        
        if captureSession.canAddInput(backCameraInput) {
            captureSession.addInput(backCameraInput)
        }
        
        // Photo Output
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray( [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])],
                                                    completionHandler: nil)
        
        
        guard let photoOutput = photoOutput else { return }
        
        photoOutput.isHighResolutionCaptureEnabled = true // Required for isHighResolutionPhotoEnabled of AVCapturePhotoSettings, default is false
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
        }
        
        applyDefaultZoom()
        
        startRunningCaptureSession()
    }
    
    private func setupVideoInputOutput() {
        // Camera Device Input
        if let cameraDeviceInput = cameraDeviceInput(type: .back) {
            if captureSession.canAddInput(cameraDeviceInput) {
                captureSession.addInput(cameraDeviceInput)
            }
        }
        
        // Audio Input
        if let audioInput = audioInput() {
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        }
        
        // Video Output
        videoOutput = AVCaptureMovieFileOutput()
        guard let videoOutput = videoOutput else { return }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        applyDefaultZoom()
        
        startRunningCaptureSession()
    }
    
    private func cameraDeviceInput(type: AVCaptureDevice.Position) -> AVCaptureDeviceInput?  {
        
        let deviceTypes = [ AVCaptureDevice.DeviceType.builtInTripleCamera,
                            AVCaptureDevice.DeviceType.builtInDualWideCamera,
                            AVCaptureDevice.DeviceType.builtInDualCamera,
                            AVCaptureDevice.DeviceType.builtInWideAngleCamera ]
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: type).devices
        
        for device in devices where device.position == type {
            return try? AVCaptureDeviceInput(device: device)
        }
        
        return nil
    }
    
    private func audioInput() -> AVCaptureDeviceInput? {
        
        if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)   {
            return try? AVCaptureDeviceInput(device: audioDevice)
        }
        return nil
    }
    
    private func releasePreview() {
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        let outputs = captureSession.outputs
        for output in outputs {
            captureSession.removeOutput(output)
        }
        
        if let videoOutput = videoOutput, videoOutput.isRecording {
            videoOutput.stopRecording()
        }
        captureSession.stopRunning()
        
        currentZoomFactor = 1.0
    }
    
    private func inputCameraPosition() -> AVCaptureDevice.Position? {
        return inputCamera()?.position
    }
    
    private func cameraInput() -> AVCaptureDeviceInput? {
        captureSession.inputs
            .compactMap { $0 as? AVCaptureDeviceInput }
            .first { $0.device.hasMediaType(.video) }
    }
    
    private func inputCamera() -> AVCaptureDevice? {
        cameraInput()?.device
    }
    
    func checkCameraPermission() {
        DispatchQueue.main.async {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.checkMicrophonePermission()
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.checkMicrophonePermission()
                    } else {
                        self.shouldCloseCamera = true
                    }
                }
                
            case .denied:
                self.shouldShowPermission = true
                self.shouldCloseCamera = false
                
            case .restricted:
                self.shouldShowPermission = true
                self.shouldCloseCamera = false
                
                return
            @unknown default:
                break
            }
        }
    }
    
    func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .denied:
            shouldShowPermission = true
            
        case .restricted:
            shouldShowPermission = true
            
        case .authorized:
            self.setup()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { success in
                if success {
                    self.setup()
                } else {
                    self.shouldCloseCamera = true
                }
            }
        @unknown default:
            break
        }
    }
}

extension CameraService  {
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        self.imageCompletion = CameraImageCompletion(capturePhoto: photo,
                                                     currentLocation: locationManager.currentLocation)
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput,
                           didFinishRecordingTo outputFileURL: URL,
                           from connections: [AVCaptureConnection],
                           error: Error?) {
        if error != nil {
            DispatchQueue.main.async {
                self.shouldShowProgressView = false
                self.isRecording = false
            }
            return
        }
        
        self.videoURLCompletion =  outputFileURL
        self.isRecording = false
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        self.isRecording = true
    }
}

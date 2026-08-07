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
    var shouldPreserveMetadata: Bool = false
    
    // Zoom factor of the device when the pinch gesture began
    private var initialZoomFactor: CGFloat = 1.0
    
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
        
        if let avDevice = (captureSession.inputs.first as? AVCaptureDeviceInput)?.device {
            
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
        initialZoomFactor = inputCamera()?.videoZoomFactor ?? 1.0
    }
    
    /// Applies the pinch scale to the zoom captured at gesture start, clamped to the allowed range.
    func zoom(by pinchScale: CGFloat) {
        guard let device = inputCamera() else { return }
        
        let desiredZoomFactor = initialZoomFactor * pinchScale
        let clampedZoomFactor = max(device.minAvailableVideoZoomFactor,
                                    min(desiredZoomFactor, maximumZoomFactor(for: device)))
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clampedZoomFactor
            device.unlockForConfiguration()
            currentZoomFactor = displayedZoomFactor(for: device)
        } catch {
        }
    }
    
    /// Max zoom: the system's recommended range on iOS 18+, otherwise 5x the longest lens like the native Camera app
    private func maximumZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *),
           let range = device.activeFormat.systemRecommendedVideoZoomRange {
            return min(range.upperBound, device.maxAvailableVideoZoomFactor)
        }
        
        let longestLensZoomFactor = device.virtualDeviceSwitchOverVideoZoomFactors.last
            .map { CGFloat(truncating: $0) } ?? 1.0
        
        return min(longestLensZoomFactor * 5.0,
                   device.maxAvailableVideoZoomFactor)
    }
    
    /// Converts the zoom factor into the user facing value, so the wide lens reads as 1x.
    private func displayedZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *) {
            return device.videoZoomFactor * device.displayVideoZoomFactorMultiplier
        }
        
        return device.videoZoomFactor / defaultZoomFactor(for: device)
    }
    
    /// The device's internal zoom factor for the main wide lens (what the user sees as "1x").
    private func defaultZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        guard device.constituentDevices.first?.deviceType == .builtInUltraWideCamera,
              let wideLensFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first else {
            return 1.0
        }
        return CGFloat(truncating: wideLensFactor)
    }
    
    /// Resets the camera to the "1x" wide lens whenever a new input is installed
    private func applyDefaultZoom() {
        guard let device = inputCamera() else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = defaultZoomFactor(for: device)
            device.unlockForConfiguration()
        } catch {
        }
        currentZoomFactor = 1.0
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

//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine
import CoreLocation

public class CameraService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    struct CameraImageCompletion {
        let imageData: Data
        var currentLocation: CLLocation?
    }
    
    // MARK: - Private properties
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var  deviceOrientation : UIDeviceOrientation = UIDevice.current.orientation
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var locationManager = LocationManager()
    var currentLocation: CLLocation?
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
    
    var cameraType : CameraType = .image {
        didSet {
            stopRunningCaptureSession()
            releasePreview()
            cameraType == .video ? setupVideoInputOutput() : setupPhotoInputOutput()
        }
    }
    
    func startRunningCaptureSession() {
        if shouldPreserveMetadata {
            locationManager.initializeLocationManager()
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
        let settings = AVCapturePhotoSettings()
        guard let delegate = captureDelegate else {
            return
        }
        if let photoOutputConnection = self.photoOutput?.connection(with: .video) {
            photoOutputConnection.videoOrientation = deviceOrientation.videoOrientation()
        }
        photoOutput?.capturePhoto(with: settings, delegate: delegate)
        shouldShowProgressView = true
    }
    
    func startCaptureVideo() {
        if let videoOutput = videoOutput, videoOutput.isRecording {
            videoOutput.stopRecording()
            shouldShowProgressView = true
        } else {
            let outFileUrl = createTempFileURL()
            guard let delegate = videoRecordingDelegate else {
                return
            }
            
            if let videoOutputConnection = self.videoOutput?.connection(with: .video) {
                videoOutputConnection.videoOrientation = deviceOrientation.videoOrientation()
            }
            
            if shouldPreserveMetadata {
                // Add location to the video output
                guard let currentLocation = locationManager.currentLocation else { return }
                videoOutput?.add(location: currentLocation)
            }
            
            videoOutput?.startRecording(to: outFileUrl, recordingDelegate: delegate )
        }
    }
    
    func toggleCameraType() {
        guard let inputCameraPosition = inputCameraPosition() else {
            return
        }
        if let currentInput = captureSession.inputs.first   {
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
        captureSession.sessionPreset = AVCaptureSession.Preset.high
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
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
        }
        
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
        
        startRunningCaptureSession()
    }
    
    private func cameraDeviceInput(type: AVCaptureDevice.Position) -> AVCaptureDeviceInput?  {
        let deviceTypes = [ AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInWideAngleCamera ]
        
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
        
    }
    
    private func inputCameraPosition() -> AVCaptureDevice.Position? {
        return inputCamera()?.position
    }
    
    private func inputCamera() -> AVCaptureDevice? {
        return (captureSession.inputs.first as? AVCaptureDeviceInput)?.device
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
        if let data = photo.fileDataRepresentation() {
            self.imageCompletion = CameraImageCompletion(imageData: data, currentLocation: currentLocation)
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput,
                           didFinishRecordingTo outputFileURL: URL,
                           from connections: [AVCaptureConnection],
                           error: Error?) {
        self.videoURLCompletion =  outputFileURL
        self.isRecording = false
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        self.isRecording = true
    }
}

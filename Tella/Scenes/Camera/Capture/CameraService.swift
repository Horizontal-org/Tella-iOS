//
//  CameraService.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 12/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation
import Combine
import UIKit

final class CameraService: ObservableObject, @unchecked Sendable {
    
    // MARK: - Types
    
    enum RecordingState: Equatable {
        case idle, starting, recording, stopping
    }
    
    struct CapturedPhoto {
        let photo: AVCapturePhoto
        let aspectRatio: CGFloat
    }
    
    enum CaptureError: Error, Equatable {
        case cameraUnavailable
        case captureFailed
        case insufficientStorage
    }
    
    private struct PendingPhoto {
        let aspectRatio: CGFloat
        let continuation: CheckedContinuation<CapturedPhoto, Error>
    }
    
    // MARK: - Session and events
    
    let captureSession = AVCaptureSession()
    let captureFailed = PassthroughSubject<Error?, Never>()
    let captureWarning = PassthroughSubject<CaptureError, Never>()
    let cameraCloseRequested = PassthroughSubject<Void, Never>()
    
    // MARK: - Published state
    
    @Published private(set) var shouldShowPermission = false
    @Published private(set) var recordingState: RecordingState = .idle
    @Published private(set) var currentZoomFactor: CGFloat = 1.0
    @Published private(set) var availableZoomLevels: [CameraZoomLevel] = []
    @Published private(set) var flashMode: CameraFlashMode = .off
    @Published private(set) var isFlashAvailable = false
    
    // MARK: - Configuration
    
    var shouldPreserveMetadata = false
    
    var cameraType: CameraType = .image {
        didSet {
            guard cameraType != oldValue, isCameraActive else { return }
            requestCaptureSession()
        }
    }
    
    // MARK: - Dependencies
    
    private let sessionQueue = DispatchQueue(label: "org.tella.camera.session",
                                             qos: .userInitiated)
    private let locationManager = LocationManager()
    private let orientationHelper = DeviceOrientationHelper()
    private let zoomController = CameraZoomController()
    private let photoCapture = CameraPhotoCapture()
    private let videoCapture = CameraVideoCapture()
    
    // MARK: - Main queue state
    
    private var deviceOrientation: UIDeviceOrientation = {
        let orientation = UIDevice.current.orientation
        return orientation.isValidInterfaceOrientation ? orientation : .portrait
    }()
    private var isCameraActive = false
    private var permissionRequestID: UUID?
    
    // MARK: - Session queue state
    
    private var isSessionActive = false
    private var sessionRecordingState: RecordingState = .idle
    private var requestedCameraType: CameraType = .image
    private var requestedFlashMode: CameraFlashMode = .off
    private var configuredCameraType: CameraType?
    private var pendingPhotos: [Int64: PendingPhoto] = [:]
    private var recordingContinuation: CheckedContinuation<CameraVideoCapture.Recording, Error>?
    
    // MARK: - Initialization
    
    init() {
        configureCaptureCallbacks()
    }
}

extension CameraService {
    
    // MARK: - Session lifecycle
    
    func resumeOrSetupCaptureSession() {
        isCameraActive = true
        requestCaptureSession()
    }
    
    /// Stops the camera but lets a capture that is already underway finish and be delivered.
    func stopRunningCaptureSession() {
        guard isCameraActive else { return }
        isCameraActive = false
        permissionRequestID = nil
        orientationHelper.stopDeviceOrientationNotifier()
        locationManager.stopUpdatingLocation()
        stopRecordingVideo()
        sessionQueue.async {
            self.isSessionActive = false
            CameraFlashController.turnOffTorch(device: self.inputCamera)
            if self.sessionRecordingState == .idle {
                self.stopSessionIfFinished()
            } else {
                self.requestRecordingStop()
            }
        }
    }
    
    /// Stops the camera and drops whatever is in flight: pending photos are cancelled and a
    /// recording is stopped and its file removed. Used when the app locks, so nothing from
    /// the camera outlives the lock or lands in the temp directory after it is swept.
    func discardCaptures() {
        stopRunningCaptureSession()
        sessionQueue.async {
            let photos = Array(self.pendingPhotos.values)
            self.pendingPhotos.removeAll()
            let recording = self.recordingContinuation
            self.recordingContinuation = nil
            self.stopSessionIfFinished()
            photos.forEach { $0.continuation.resume(throwing: CancellationError()) }
            recording?.resume(throwing: CancellationError())
        }
    }
    
    // MARK: - Capture requests
    
    /// Suspends until the photo has been processed, even if the camera closes in the meantime.
    /// Throws `CaptureError.cameraUnavailable` when no capture was attempted.
    @MainActor
    func takePhoto(aspectRatio: CameraAspectRatio) async throws -> CapturedPhoto {
        guard isCameraActive, cameraType == .image else { throw CaptureError.cameraUnavailable }
        let portraitAspectRatio = aspectRatio.widthOverHeight
        let orientation = deviceOrientation.videoOrientation()
        let mode = flashMode
        let location = shouldPreserveMetadata ? locationManager.currentLocation : nil
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                guard self.isSessionActive, self.configuredCameraType == .image,
                      self.captureSession.isRunning, !self.captureSession.isInterrupted,
                      self.photoCapture.photoOutput != nil else {
                    continuation.resume(throwing: CaptureError.captureFailed)
                    return
                }
                let settings = self.photoCapture.makeHEVCPhotoSettings(flashMode: mode.photoFlashMode)
                self.pendingPhotos[settings.uniqueID] = PendingPhoto(aspectRatio: portraitAspectRatio,
                                                                     continuation: continuation)
                if let location {
                    settings.add(location: location)
                }
                if !self.photoCapture.takePhoto(orientation: orientation, settings: settings) {
                    self.pendingPhotos.removeValue(forKey: settings.uniqueID)
                    continuation.resume(throwing: CaptureError.captureFailed)
                }
            }
        }
    }
    
    /// Starts recording and suspends until the recording ends, even if the camera closes in
    /// the meantime; end it with `stopRecordingVideo()`. Throws `CaptureError.cameraUnavailable`
    /// when no recording was attempted.
    @MainActor
    func recordVideo() async throws -> CameraVideoCapture.Recording {
        guard isCameraActive, cameraType == .video, recordingState == .idle else {
            throw CaptureError.cameraUnavailable
        }
        recordingState = .starting
        let orientation = deviceOrientation.videoOrientation()
        let location = shouldPreserveMetadata ? locationManager.currentLocation : nil
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                self.recordingContinuation = continuation
                guard self.isSessionActive, self.configuredCameraType == .video,
                      self.captureSession.isRunning, !self.captureSession.isInterrupted,
                      self.hasVideoConfiguration,
                      self.sessionRecordingState == .idle else {
                    self.recordingStartFailed()
                    return
                }
                self.sessionRecordingState = .starting
                self.updateFlashMode()
                if !self.videoCapture.startRecording(orientation: orientation, location: location) {
                    self.recordingStartFailed()
                }
            }
        }
    }
    
    func stopRecordingVideo() {
        guard recordingState == .starting || recordingState == .recording else { return }
        recordingState = .stopping
        sessionQueue.async { self.requestRecordingStop() }
    }
    
    // MARK: - Camera controls
    
    func toggleCameraPosition() {
        guard isCameraActive, recordingState == .idle else { return }
        sessionQueue.async {
            guard self.isSessionActive, self.sessionRecordingState == .idle else { return }
            CameraFlashController.turnOffTorch(device: self.inputCamera)
            guard CameraSessionConfigurator.toggleCamera(in: self.captureSession) else {
                self.updateFlashMode()
                return
            }
            self.photoCapture.applyResolution(device: self.inputCamera)
            self.updateCameraControls(resetZoom: true)
            self.updateFlashMode()
        }
    }
    
    func setFlashMode(_ mode: CameraFlashMode) {
        flashMode = mode
        sessionQueue.async {
            self.requestedFlashMode = mode
            self.updateFlashMode()
        }
    }
    
    func startZoom() {
        sessionQueue.async {
            guard self.isSessionActive else { return }
            self.zoomController.startZoom(device: self.inputCamera)
        }
    }
    
    func zoom(by pinchScale: CGFloat) {
        sessionQueue.async {
            guard self.isSessionActive, let device = self.inputCamera else { return }
            let factor = self.zoomController.zoom(by: pinchScale, device: device)
            DispatchQueue.main.async { self.currentZoomFactor = factor }
        }
    }
    
    func setZoom(to level: CameraZoomLevel) {
        sessionQueue.async {
            guard self.isSessionActive, let device = self.inputCamera else { return }
            let factor = self.zoomController.setZoom(to: level, device: device)
            DispatchQueue.main.async { self.currentZoomFactor = factor }
        }
    }
    
    // MARK: - Failure reporting
    
    func reportCaptureFailure(_ error: Error? = nil) {
        captureFailed.send(error)
    }
}

private extension CameraService {
    
    // MARK: - Permissions
    
    func requestCaptureSession() {
        let requestID = UUID()
        permissionRequestID = requestID
        let type = cameraType
        CameraPermissionHandler.check(for: type) { [weak self] result in
            guard let self, self.isCameraActive,
                  self.permissionRequestID == requestID else { return }
            self.permissionRequestID = nil
            switch result {
            case .authorized:
                self.shouldShowPermission = false
                self.orientationHelper.startDeviceOrientationNotifier { [weak self] orientation in
                    self?.deviceOrientation = orientation
                }
                if self.shouldPreserveMetadata {
                    self.locationManager.startUpdatingLocation()
                } else {
                    self.locationManager.stopUpdatingLocation()
                }
                let mode = self.flashMode
                self.sessionQueue.async {
                    self.isSessionActive = true
                    self.requestedCameraType = type
                    self.requestedFlashMode = mode
                    self.activateSession()
                }
            case .showSettings:
                self.shouldShowPermission = true
            case .close:
                self.cameraCloseRequested.send(())
            }
        }
    }
    
    // MARK: - Session configuration (session queue)
    
    var inputCamera: AVCaptureDevice? {
        CameraSessionConfigurator.videoDevice(in: captureSession)
    }
    
    var hasVideoConfiguration: Bool {
        videoCapture.videoOutput != nil
        && CameraSessionConfigurator.hasAudioInput(in: captureSession)
    }
    
    func activateSession() {
        guard isSessionActive, sessionRecordingState == .idle else { return }
        let type = requestedCameraType
        let needsVideoConfiguration = type == .video && !hasVideoConfiguration
        if inputCamera == nil || photoCapture.photoOutput == nil {
            setupSession(type: type)
        } else if configuredCameraType != type || needsVideoConfiguration {
            switchCaptureMode(to: type)
        }
        guard inputCamera != nil, photoCapture.photoOutput != nil,
              type != .video || hasVideoConfiguration else {
            DispatchQueue.main.async { self.reportCaptureFailure() }
            return
        }
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        guard captureSession.isRunning else {
            DispatchQueue.main.async { self.reportCaptureFailure() }
            return
        }
        updateFlashMode()
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    /// Stops the session once the camera has closed and no capture is still being delivered.
    func stopSessionIfFinished() {
        guard !isSessionActive, pendingPhotos.isEmpty, sessionRecordingState == .idle else { return }
        stopSession()
    }
    
    func setupSession(type: CameraType) {
        let position = inputCamera?.position ?? .back
        CameraFlashController.turnOffTorch(device: inputCamera)
        captureSession.beginConfiguration()
        CameraSessionConfigurator.removeAllInputsAndOutputs(from: captureSession)
        photoCapture.reset()
        videoCapture.reset()
        CameraSessionConfigurator.applyPreset(for: type, to: captureSession)
        
        if CameraSessionConfigurator.addCameraInput(position: position, to: captureSession) {
            photoCapture.attach(to: captureSession)
            if type == .video {
                videoCapture.attach(to: captureSession)
                CameraSessionConfigurator.addAudioInput(to: captureSession)
            }
        }
        captureSession.commitConfiguration()
        configuredCameraType = type
        updateCameraControls(resetZoom: true)
    }
    
    func switchCaptureMode(to type: CameraType) {
        captureSession.beginConfiguration()
        if type == .video {
            CameraSessionConfigurator.applyPreset(for: type, to: captureSession)
            videoCapture.attach(to: captureSession)
            CameraSessionConfigurator.addAudioInput(to: captureSession)
        } else {
            videoCapture.detach(from: captureSession)
            CameraSessionConfigurator.removeAudioInput(from: captureSession)
            CameraSessionConfigurator.applyPreset(for: type, to: captureSession)
        }
        captureSession.commitConfiguration()
        photoCapture.applyResolution(device: inputCamera)
        configuredCameraType = type
        updateCameraControls(resetZoom: true)
    }
    
    // MARK: - Recording lifecycle (session queue)
    
    func requestRecordingStop() {
        guard sessionRecordingState == .starting || sessionRecordingState == .recording else { return }
        sessionRecordingState = .stopping
        if videoCapture.isRecording {
            videoCapture.stopRecording()
        }
        updateFlashMode()
    }
    
    func recordingStartFailed() {
        sessionRecordingState = .idle
        let continuation = recordingContinuation
        recordingContinuation = nil
        updateFlashMode()
        if !isSessionActive {
            stopSession()
        }
        DispatchQueue.main.async {
            self.recordingState = .idle
            continuation?.resume(throwing: CaptureError.captureFailed)
        }
    }
    
    func handleRecordingStarted() {
        if sessionRecordingState == .stopping || !isSessionActive {
            videoCapture.stopRecording()
            return
        }
        guard sessionRecordingState == .starting else { return }
        sessionRecordingState = .recording
        DispatchQueue.main.async {
            guard self.recordingState == .starting else { return }
            self.recordingState = .recording
        }
    }
    
    func handleRecordingFinished(_ result: Result<CameraVideoCapture.Recording, Error>) {
        sessionRecordingState = .idle
        let continuation = recordingContinuation
        recordingContinuation = nil
        if isSessionActive {
            activateSession()
        } else {
            CameraFlashController.turnOffTorch(device: inputCamera)
            stopSession()
        }
        // A discarded recording has no one waiting for it; do not leave its file behind.
        if continuation == nil, case .success(let recording) = result {
            try? FileManager.default.removeItem(at: recording.url)
        }
        DispatchQueue.main.async {
            self.recordingState = .idle
            switch result {
            case .failure(let error):
                debugLog("Unable to record video: \(error.localizedDescription)")
            case .success(let recording):
                if let warning = recording.warning {
                    debugLog("Video recording ended: \(warning.localizedDescription)")
                    if warning.isInsufficientStorageError {
                        self.captureWarning.send(.insufficientStorage)
                    }
                }
            }
            continuation?.resume(with: result)
        }
    }
    
    // MARK: - Capture callbacks
    
    func configureCaptureCallbacks() {
        photoCapture.onPhotoCaptured = { [weak self] captureID, photo, error in
            guard let self else { return }
            self.sessionQueue.async {
                // Removing the entry first guarantees the continuation resumes exactly once,
                // since both delegate callbacks can report the same capture.
                guard let pending = self.pendingPhotos.removeValue(forKey: captureID) else { return }
                self.stopSessionIfFinished()
                if let error {
                    pending.continuation.resume(throwing: error)
                } else if let photo {
                    pending.continuation.resume(returning: CapturedPhoto(photo: photo,
                                                                         aspectRatio: pending.aspectRatio))
                } else {
                    pending.continuation.resume(throwing: CaptureError.captureFailed)
                }
            }
        }
        videoCapture.onRecordingStarted = { [weak self] in
            guard let self else { return }
            self.sessionQueue.async { self.handleRecordingStarted() }
        }
        videoCapture.onRecordingFinished = { [weak self] result in
            guard let self else { return }
            self.sessionQueue.async { self.handleRecordingFinished(result) }
        }
    }
    
    // MARK: - Device controls (session queue)
    
    func updateFlashMode() {
        guard isSessionActive else {
            CameraFlashController.turnOffTorch(device: inputCamera)
            return
        }
        if configuredCameraType == .video {
            CameraFlashController.applyVideoTorch(device: inputCamera,
                                                  flashMode: requestedFlashMode,
                                                  isRecording: sessionRecordingState == .starting
                                                  || sessionRecordingState == .recording)
        } else {
            CameraFlashController.turnOffTorch(device: inputCamera)
            photoCapture.prepareCaptureSettings(flashMode: requestedFlashMode)
        }
    }
    
    func updateCameraControls(resetZoom: Bool) {
        let device = inputCamera
        let isFlashAvailable = configuredCameraType == .video
        ? device?.hasTorch ?? false
        : device?.hasFlash ?? false
        let factor = device.map {
            resetZoom ? zoomController.applyDefaultZoom(device: $0)
            : zoomController.displayedZoomFactor(for: $0)
        } ?? 1.0
        let levels = zoomController.availableZoomLevels(device: device)
        DispatchQueue.main.async {
            self.currentZoomFactor = factor
            self.availableZoomLevels = levels
            self.isFlashAvailable = isFlashAvailable
        }
    }
}

//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

struct CameraStatusChipState: Equatable {
    let title: String
    let isOn: Bool
}

class CameraViewModel: ObservableObject {
    
    // MARK: - Context and bindings
    
    var mainAppModel: MainAppModel
    var rootFile: VaultFileDB?
    var sourceView: SourceView
    var resultFile: Binding<[VaultFileDB]?>?
    var showingCameraView: Binding<Bool>
    
    // MARK: - Capture state
    
    @Published var lastImageOrVideoVaultFile: VaultFileDB?
    @Published var cameraState: CameraState = .readyTakingImage
    @Published private(set) var isRecordingTransitioning = false
    @Published private(set) var isFlippingCamera = false
    @Published var formattedCurrentTime: String = "00:00:00"
    @Published var currentTime: TimeInterval = 0.0
    
    // MARK: - Capture options
    
    @Published var gridIsOn: Bool = false
    @Published var photoAspectRatio: CameraAspectRatio = .threeByFour
    @Published var flashMode: CameraFlashMode = .off
    @Published var isFlashAvailable = false
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var availableZoomLevels: [CameraZoomLevel] = []
    
    // MARK: - Menu state
    
    @Published var showingMoreActions: Bool = false
    @Published var showingFlashOptions: Bool = false
    @Published var showingAspectOptions: Bool = false
    
    // MARK: - Presentation state
    
    @Published var progressFile: ProgressFile = ProgressFile()
    @Published var shouldShowToast: Bool = false
    @Published var shouldShowPermission: Bool = false
    @Published var shouldPresentProgressView: Bool = false
    @Published var statusChip: CameraStatusChipState?
    var errorMessage: String = ""
    
    // MARK: - Computed properties
    
    var session: AVCaptureSession {
        service.captureSession
    }
    
    var shouldShowProgressView: Bool {
        resultFile != nil
    }
    
    var aspectRatioTitle: String {
        photoAspectRatio.title
    }
    
    var videoResolutionTitle: String {
        "HD"
    }
    
    // MARK: - Dependencies
    
    private let service: CameraService
    private let mediaImporter: CameraMediaImporter
    
    // MARK: - Private state
    
    private var cancellable: Set<AnyCancellable> = []
    private var timer = Timer()
    private var recordingStartedAt: Date?
    private var statusChipHideWorkItem: DispatchWorkItem?
    
    // MARK: - Initialization
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFileDB?,
         resultFile: Binding<[VaultFileDB]?>? = nil,
         sourceView: SourceView,
         showingCameraView: Binding<Bool> = .constant(false)) {
        
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile
        self.resultFile = resultFile
        self.sourceView = sourceView
        self.showingCameraView = showingCameraView
        self.service = CameraService()
        self.mediaImporter = CameraMediaImporter(mainAppModel: mainAppModel,
                                                 rootFile: rootFile,
                                                 resultFile: resultFile,
                                                 sourceView: sourceView)
        
        updateLastItem()
        configureMediaImporter()
        listenToShouldReloadFiles()
        listenToCameraService()
        listenToAppLifecycle()
    }
    
    // MARK: - Camera lifecycle
    
    func configure() {
        service.shouldPreserveMetadata = mainAppModel.settings.preserveMetadata
        service.resumeOrSetupCaptureSession()
    }
    
    func stopRunningCaptureSession() {
        invalidateTimerRunning()
        service.stopRunningCaptureSession()
    }
    
    func dismissCamera() {
        hideMenu()
        stopRunningCaptureSession()
        if sourceView == .tab {
            mainAppModel.selectedTab = .home
        } else {
            showingCameraView.wrappedValue = false
        }
    }
    
    private func handleForcedClose() {
        dismissCamera()
    }
    
    /// The lock tears this screen down and sweeps the temp directory right after, so nothing
    /// from the camera should still be in flight: a pending photo is dropped and a recording
    /// is discarded instead of being saved.
    private func clearCamera() {
        invalidateTimerRunning()
        service.discardCaptures()
    }
    
    // MARK: - Capture requests
    
    /// The suspended task holds the service and importer, so the photo is saved even if this
    /// model is released before the capture is delivered.
    func capturePhoto() {
        hideMenu()
        let service = service
        let importer = mediaImporter
        let aspectRatio = photoAspectRatio
        presentProgressViewIfNeeded()
        Task { @MainActor [weak self] in
            do {
                let capture = try await service.takePhoto(aspectRatio: aspectRatio)
                importer.save(capture)
            } catch CameraService.CaptureError.cameraUnavailable, is CancellationError {
                self?.shouldPresentProgressView = false
            } catch {
                self?.displayError()
            }
        }
    }
    
    /// The task holds the service until the recording ends,
    /// so a video also survives closing the camera mid-recording.
    func startRecordingVideo() {
        guard cameraState == .readyRecordingVideo, !isRecordingTransitioning else { return }
        hideMenu()
        let service = service
        let importer = mediaImporter
        Task { @MainActor [weak self] in
            do {
                let recording = try await service.recordVideo()
                self?.presentProgressViewIfNeeded()
                importer.save(videoAt: recording.url)
            } catch CameraService.CaptureError.cameraUnavailable, is CancellationError {
                // Nothing was recorded, or the recording was discarded for the lock.
            } catch {
                self?.displayError()
            }
        }
    }
    
    func stopRecordingVideo() {
        hideMenu()
        service.stopRecordingVideo()
    }
    
    // MARK: - Camera controls
    
    func selectCameraType(_ cameraType: CameraType) {
        guard !cameraState.isRecording, !isRecordingTransitioning,
              cameraState.cameraType != cameraType else { return }
        
        hideMenu()
        withAnimation(.easeInOut(duration: CameraStyle.Animations.modeChange)) {
            cameraState = CameraState(cameraType: cameraType)
        }
        
        service.cameraType = cameraType
    }
    
    func toggleCameraPosition() {
        guard !isFlippingCamera, !cameraState.isRecording, !isRecordingTransitioning else { return }
        hideMenu()
        isFlippingCamera = true
        let service = service
        Task { @MainActor [weak self] in
            await service.toggleCameraPosition()
            self?.isFlippingCamera = false
        }
    }
    
    // MARK: - Zoom controls
    
    func startZoom() {
        hideMenu()
        service.startZoom()
    }
    
    func zoom(by pinchScale: CGFloat) {
        service.zoom(by: pinchScale)
    }
    
    func setZoom(to level: CameraZoomLevel) {
        hideMenu()
        service.setZoom(to: level)
    }
    
    // MARK: - More actions
    
    func toggleMoreActions() {
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingFlashOptions = false
            showingAspectOptions = false
            showingMoreActions.toggle()
        }
    }
    
    func hideMoreActions() {
        guard showingMoreActions else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingMoreActions = false
        }
    }
    
    func hideMenu() {
        hideMoreActions()
        hideFlashOptions()
        hideAspectOptions()
    }
    
    func moreActionsAspectTapped() {
        showAspectOptions()
    }
    
    func moreActionsResolutionTapped() {
        // TODO: video resolution
    }
    
    func moreActionsSettingsTapped() {
        // TODO: camera settings
    }
    
    // MARK: - Flash options
    
    func selectFlashMode(_ mode: CameraFlashMode) {
        service.setFlashMode(mode)
    }
    
    func showFlashOptions() {
        guard isFlashAvailable else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingMoreActions = false
            showingAspectOptions = false
            showingFlashOptions = true
        }
    }
    
    func hideFlashOptions() {
        guard showingFlashOptions else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingFlashOptions = false
        }
    }
    
    func goBackFromFlashOptions() {
        guard showingFlashOptions else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingFlashOptions = false
            showingAspectOptions = false
            showingMoreActions = true
        }
    }
    
    // MARK: - Aspect ratio options
    
    func selectPhotoAspectRatio(_ ratio: CameraAspectRatio) {
        guard photoAspectRatio != ratio else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.aspectRatio)) {
            photoAspectRatio = ratio
        }
    }
    
    func showAspectOptions() {
        guard cameraState.cameraType == .image else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingMoreActions = false
            showingFlashOptions = false
            showingAspectOptions = true
        }
    }
    
    func hideAspectOptions() {
        guard showingAspectOptions else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingAspectOptions = false
        }
    }
    
    func goBackFromAspectOptions() {
        guard showingAspectOptions else { return }
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            showingAspectOptions = false
            showingFlashOptions = false
            showingMoreActions = true
        }
    }
    
    // MARK: - Grid and status feedback
    
    func toggleGrid() {
        hideMenu()
        gridIsOn.toggle()
        presentStatusChip(isOn: gridIsOn)
    }
    
    private func presentStatusChip(isOn: Bool) {
        statusChipHideWorkItem?.cancel()
        
        let chip = CameraStatusChipState(title: isOn
                                         ? LocalizableCamera.gridOn.localized
                                         : LocalizableCamera.gridOff.localized,
                                         isOn: isOn)
        
        withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
            statusChip = chip
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeInOut(duration: CameraStyle.Animations.moreActions)) {
                self?.statusChip = nil
            }
        }
        statusChipHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + CameraStyle.Animations.statusChip,
                                      execute: workItem)
    }
    
    // MARK: - Recording timer
    
    func initialiseTimerRunning() {
        invalidateTimerRunning()
        recordingStartedAt = Date()
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerRunning()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func invalidateTimerRunning() {
        timer.invalidate()
        recordingStartedAt = nil
        currentTime = 0.0
        formattedCurrentTime = currentTime.formattedAsHHMMSS()
    }
    
    private func timerRunning() {
        guard let recordingStartedAt else { return }
        currentTime = Date().timeIntervalSince(recordingStartedAt)
        formattedCurrentTime = currentTime.formattedAsHHMMSS()
    }
    
    // MARK: - Subscriptions
    
    private func listenToCameraService() {
        // CameraService publishes recording transitions on the main queue.
        service.$recordingState
            .sink { [weak self] state in
                guard let self else { return }
                self.isRecordingTransitioning = state == .starting || state == .stopping
                switch state {
                case .recording:
                    withAnimation(.easeInOut(duration: CameraStyle.Animations.recording)) {
                        self.cameraState = .recordingVideo
                    }
                    self.initialiseTimerRunning()
                case .idle:
                    if self.cameraState.isRecording {
                        withAnimation(.easeInOut(duration: CameraStyle.Animations.recording)) {
                            self.cameraState = .readyRecordingVideo
                        }
                    }
                    self.invalidateTimerRunning()
                case .starting, .stopping:
                    break
                }
            }
            .store(in: &cancellable)
        
        service.captureFailed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.displayError() }
            .store(in: &cancellable)
        
        service.$shouldShowPermission
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.shouldShowPermission = $0 }
            .store(in: &cancellable)
        
        service.cameraCloseRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleForcedClose()
            }
            .store(in: &cancellable)
        
        service.$currentZoomFactor
            .sink { [weak self] in self?.currentZoomFactor = $0 }
            .store(in: &cancellable)
        
        service.$availableZoomLevels
            .sink { [weak self] in self?.availableZoomLevels = $0 }
            .store(in: &cancellable)
        
        service.$flashMode
            .sink { [weak self] in self?.flashMode = $0 }
            .store(in: &cancellable)
        
        service.$isFlashAvailable
            .sink { [weak self] isAvailable in
                self?.isFlashAvailable = isAvailable
                if !isAvailable {
                    self?.hideFlashOptions()
                }
            }
            .store(in: &cancellable)
    }
    
    private func listenToAppLifecycle() {
        // Sent on the main queue right before the app locks; handled synchronously so the
        // camera is cleared before the temp directory is swept.
        mainAppModel.$shouldSaveCurrentData
            .filter { $0 }
            .sink { [weak self] _ in self?.clearCamera() }
            .store(in: &cancellable)
    }
    
    private func listenToShouldReloadFiles() {
        mainAppModel.vaultFilesManager?.shouldReloadFiles.sink { [weak self] shouldReloadVaultFiles in
            if shouldReloadVaultFiles {
                self?.updateLastItem()
            }
        }.store(in: &cancellable)
    }
    
    // MARK: - Gallery updates
    
    private func updateLastItem() {
        DispatchQueue.main.async {
            self.lastImageOrVideoVaultFile = self.mainAppModel.vaultFilesManager?.getLatestPhotoVideoFile()
        }
    }
    
    // MARK: - Import progress
    
    private func configureMediaImporter() {
        mediaImporter.onProgress = { [weak self] importProgress in
            guard let self else { return }
            self.progressFile.progress = importProgress.progress.value
            self.progressFile.progressFile = importProgress.progressFile.value
            self.progressFile.isFinishing = importProgress.isFinishing.value
        }
        mediaImporter.onFilesAdded = { [weak self] vaultFiles in
            self?.lastImageOrVideoVaultFile = vaultFiles.first
        }
        mediaImporter.onFailure = { [weak self] _ in
            self?.displayError()
        }
    }
    
    private func presentProgressViewIfNeeded() {
        guard shouldShowProgressView else { return }
        if !shouldPresentProgressView {
            progressFile = ProgressFile()
        }
        shouldPresentProgressView = true
    }
    
    // MARK: - Error presentation
    
    private func displayError() {
        shouldPresentProgressView = false
        errorMessage = LocalizableCommon.commonError.localized
        shouldShowToast = true
    }
}

// MARK: - Preview support

extension CameraViewModel {
    static func stub(state: CameraState = .readyTakingImage) -> CameraViewModel {
        let viewModel = CameraViewModel(mainAppModel: MainAppModel.stub(),
                                        rootFile: VaultFileDB.stub(),
                                        sourceView: .addFile)
        viewModel.cameraState = state
        viewModel.currentZoomFactor = 1
        viewModel.availableZoomLevels = [CameraZoomLevel(factor: 0.5),
                                         CameraZoomLevel(factor: 1),
                                         CameraZoomLevel(factor: 2)]
        viewModel.isFlashAvailable = true
        viewModel.photoAspectRatio = .threeByFour
        return viewModel
    }
}

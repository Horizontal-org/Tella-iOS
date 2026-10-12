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

    var autoUpload: Bool {
        sourceView != .addReportFile
    }

    var aspectRatioTitle: String {
        photoAspectRatio.title
    }

    var videoResolutionTitle: String {
        "HD"
    }

    // MARK: - Dependencies

    private let service = CameraService()
    private let photoProcessingQueue = DispatchQueue(label: "org.tella.camera.photo-processing",
                                                     qos: .userInitiated,
                                                     autoreleaseFrequency: .workItem)

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

        updateLastItem()
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
        mainAppModel.vaultManager.clearTmpDirectory()
        dismissCamera()
    }

    // MARK: - Capture requests

    func capturePhoto() {
        hideMenu()
        service.takePhoto(aspectRatio: photoAspectRatio)
    }

    func startRecordingVideo() {
        guard cameraState == .readyRecordingVideo, !isRecordingTransitioning else { return }
        hideMenu()
        service.startRecordingVideo()
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
        hideMenu()
        service.toggleCameraPosition()
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

        service.$shouldCloseCamera
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldClose in
                guard shouldClose else { return }
                self?.handleForcedClose()
            }
            .store(in: &cancellable)

        service.$shouldShowProgressView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShow in
                guard let self, self.shouldShowProgressView else { return }
                if shouldShow && !self.shouldPresentProgressView {
                    self.progressFile = ProgressFile()
                }
                self.shouldPresentProgressView = shouldShow
            }
            .store(in: &cancellable)

        service.imageCompletion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] capture in
                self?.saveImage(capture.photo, aspectRatio: capture.aspectRatio)
            }
            .store(in: &cancellable)

        service.videoURLCompletion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.saveVideo(url)
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
        mainAppModel.$shouldSaveCurrentData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldSave in
                guard let self, shouldSave,
                      self.cameraState.isRecording || self.isRecordingTransitioning else { return }
                self.stopRecordingVideo()
            }
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

    // MARK: - Media saving

    private func saveImage(_ capturePhoto: AVCapturePhoto, aspectRatio: CGFloat) {
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata
        let url = mainAppModel.vaultManager.createTempFileURL(pathExtension: FileExtension.heic.rawValue)
        // Preparing the HEIC is synchronous; the vault import already handles its own background work.
        photoProcessingQueue.async {
            do {
                try capturePhoto.saveImage(to: url,
                                          shouldPreserveMetadata: isPreserveMetadataOn,
                                          aspectRatio: aspectRatio)
                DispatchQueue.main.async { self.saveFile(urlFile: url) }
            } catch {
                debugLog("Unable to save photo: \(error.localizedDescription)")
                try? FileManager.default.removeItem(at: url)
                DispatchQueue.main.async { self.service.reportCaptureFailure(error) }
            }
        }
    }

    private func saveVideo(_ videoURL: URL) {
        saveFile(urlFile: videoURL)
    }

    private func saveFile(urlFile: URL) {
        if shouldShowProgressView {
            addVaultFileWithProgressView(urlFile: urlFile)
        } else {
            addVaultFileInBackground(urlFile: urlFile)
        }
    }

    // MARK: - Vault import and progress

    private func addVaultFileWithProgressView(urlFile: URL) {
        let importedFiles = ImportedFile(urlFile: urlFile,
                                         parentId: rootFile?.id,
                                         shouldPreserveMetadata: mainAppModel.settings.preserveMetadata,
                                         fileSource: FileSource.camera)

        mainAppModel.vaultFilesManager?.addVaultFile(importedFiles: [importedFiles])
            .sink { [weak self] importVaultFileResult in
                switch importVaultFileResult {
                case .fileAdded(let vaultFiles):
                    self?.handleSuccessAddingFiles(vaultFiles: vaultFiles)
                case .importProgress(let importProgress):
                    self?.updateProgress(importProgress: importProgress)
                }
            }.store(in: &cancellable)
    }

    private func addVaultFileInBackground(urlFile: URL) {
        let isPreserveMetadataOn = mainAppModel.settings.preserveMetadata

        let importedFile = ImportedFile(urlFile: urlFile,
                                        parentId: rootFile?.id,
                                        shouldPreserveMetadata: isPreserveMetadataOn,
                                        fileSource: .camera)

        mainAppModel.addVaultFile(importedFiles: [importedFile],
                                  autoUpload: autoUpload)
    }

    private func handleSuccessAddingFiles(vaultFiles: [VaultFileDB]) {
        updateResultFile(vaultFiles: vaultFiles)
    }

    private func updateProgress(importProgress: ImportProgress) {
        DispatchQueue.main.async {
            self.progressFile.progress = importProgress.progress.value
            self.progressFile.progressFile = importProgress.progressFile.value
            self.progressFile.isFinishing = importProgress.isFinishing.value
        }
    }

    private func updateResultFile(vaultFiles: [VaultFileDB]) {
        DispatchQueue.main.async {
            self.resultFile?.wrappedValue = vaultFiles
            self.lastImageOrVideoVaultFile = vaultFiles.first
        }
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

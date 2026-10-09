//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraControlsView: View {
    // MARK: - Public properties
    @ObservedObject var viewModel: CameraViewModel
    
    // MARK: - Private properties
    
    @StateObject private var orientationHelper = DeviceOrientationHelper()
    
    var body: some View {
        
        GeometryReader { geometry in
            let layout = CameraViewfinderLayout(bounds: CGRect(origin: .zero, size: geometry.size),
                                                aspectRatio: previewAspectRatio,
                                                safeAreaInsets: UIEdgeInsets(top: geometry.safeAreaInsets.top,
                                                                             left: geometry.safeAreaInsets.leading,
                                                                             bottom: geometry.safeAreaInsets.bottom,
                                                                             right: geometry.safeAreaInsets.trailing))
            
            ZStack(alignment: .topLeading) {
                cameraPreview
                    .cameraFrame(layout.previewFrame)
                
                headerControls
                    .frame(width: layout.headerFrame.width, height: layout.headerFrame.height)
                    .background {
                        if !layout.overlaysHeader {
                            Styles.Colors.backgroundGrey1
                                .ignoresSafeArea(edges: .top)
                        }
                    }
                    .position(x: layout.headerFrame.midX, y: layout.headerFrame.midY)
                
                recordingIndicator(previewFrame: layout.previewFrame,
                                   visiblePreviewTop: max(layout.headerFrame.maxY,
                                                          layout.previewFrame.minY))
                
                viewfinderOverlays
                    .cameraFrame(layout.optionsFrame)
                if !showsBottomMenu {
                    previewControls
                        .background(layout.overlaysZoom ? Color.clear : Styles.Colors.backgroundGrey1)
                        .cameraFrame(layout.zoomFrame)
                        .transition(.opacity)
                }
                
                captureControls
                    .background(layout.overlaysShutter ? Color.clear : Styles.Colors.backgroundGrey1)
                    .cameraFrame(layout.shutterFrame)
                
                modeSelector
                    .background {
                        if !layout.overlaysMode {
                            Styles.Colors.backgroundGrey1.ignoresSafeArea(edges: .bottom)
                        }
                    }
                    .cameraFrame(layout.modeFrame)
            }
            .animation(.easeInOut(duration: CameraStyle.Animations.aspectRatio),
                       value: previewAspectRatio)
        }
        .background(Styles.Colors.backgroundGrey1.ignoresSafeArea())
        .disabled(viewModel.isRecordingTransitioning)
        .onAppear {
            orientationHelper.startDeviceOrientationNotifier()
        }
        .onDisappear {
            orientationHelper.stopDeviceOrientationNotifier()
        }
    }
    
    // MARK: - Derived state
    
    private var rotation: CameraControlRotation {
        CameraControlRotation(deviceOrientation: orientationHelper.currentDeviceOrientation,
                              shouldAnimate: orientationHelper.shouldAnimate)
    }
    
    private var previewAspectRatio: CameraAspectRatio {
        viewModel.cameraState.cameraType == .image
        ? viewModel.photoAspectRatio
        : .nineBySixteen
    }
    
    private var showsAspectOptions: Bool {
        viewModel.showingAspectOptions && viewModel.cameraState.cameraType == .image
    }
    
    private var showsBottomMenu: Bool {
        viewModel.showingMoreActions || viewModel.showingFlashOptions || showsAspectOptions
    }
    
    // MARK: - Preview
    
    private var cameraPreview: some View {
        CameraPreview(session: viewModel.session,
                      gridIsOn: viewModel.gridIsOn,
                      onZoomBegan: viewModel.startZoom,
                      onZoomChanged: viewModel.zoom,
                      onSwipe: { direction in
            viewModel.selectCameraType(direction.cameraType)
        }, onTap: viewModel.hideMenu)
    }
    
    // MARK: - Header controls
    
    private var headerControls: some View {
        CameraHeaderControlsView(isRecording: viewModel.cameraState.isRecording,
                                 flashMode: viewModel.flashMode,
                                 isFlashAvailable: viewModel.isFlashAvailable,
                                 gridIsOn: viewModel.gridIsOn,
                                 rotation: rotation,
                                 onClose: viewModel.dismissCamera,
                                 onFlashOptions: viewModel.showFlashOptions,
                                 onToggleGrid: viewModel.toggleGrid)
    }
    
    // MARK: - Overlays
    
    @ViewBuilder
    private func recordingIndicator(previewFrame: CGRect, visiblePreviewTop: CGFloat) -> some View {
        if viewModel.cameraState.isRecording {
            ZStack {
                CustomText(viewModel.formattedCurrentTime, style: .cameraTabStyle)
                    .padding(.horizontal, .small)
                    .padding(.vertical, .tiny)
                    .background(Capsule().fill(Styles.Colors.darkRed))
                
                if let statusChip = viewModel.statusChip {
                    CameraStatusChip(title: statusChip.title,
                                     isOn: statusChip.isOn,
                                     rotation: CameraControlRotation(deviceOrientation: .portrait))
                    .offset(y: .large + .small)
                    .transition(.opacity)
                }
            }
            .rotate(rotation)
            .fixedSize()
            .position(x: previewFrame.midX,
                      y: visiblePreviewTop + .largeMedium)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
    
    private var viewfinderOverlays: some View {
        ZStack {
            CameraMoreActionsView(viewModel: viewModel, rotation: rotation)
            flashOptions
            aspectOptions
            idleStatusIndicator
        }
    }
    
    @ViewBuilder
    private var flashOptions: some View {
        if viewModel.showingFlashOptions {
            CameraFlashOptionsView(viewModel: viewModel, rotation: rotation)
                .padding(.horizontal, .normal)
                .padding(.bottom, .normal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var aspectOptions: some View {
        if showsAspectOptions {
            CameraAspectOptionsView(viewModel: viewModel, rotation: rotation)
                .padding(.horizontal, .normal)
                .padding(.bottom, .normal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var idleStatusIndicator: some View {
        if !viewModel.cameraState.isRecording,
           let statusChip = viewModel.statusChip {
            CameraStatusChip(title: statusChip.title,
                             isOn: statusChip.isOn,
                             rotation: rotation)
            .padding(.top, .small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
    
    // MARK: - Preview controls
    
    private var previewControls: some View {
        CameraPreviewControlsView(zoomLevels: viewModel.availableZoomLevels,
                                  zoomFactor: viewModel.currentZoomFactor,
                                  isRecording: viewModel.cameraState.isRecording,
                                  rotation: rotation,
                                  onSelectZoomLevel: viewModel.setZoom,
                                  onMoreOptions: viewModel.toggleMoreActions)
    }
    
    // MARK: - Capture controls
    
    private var captureControls: some View {
        CameraCaptureControlsView(mode: captureMode,
                                  file: viewModel.lastImageOrVideoVaultFile,
                                  rotation: rotation,
                                  onGallery: openGallery,
                                  onCapture: capture,
                                  onFlipCamera: viewModel.toggleCameraPosition)
    }
    
    private var captureMode: CameraCaptureMode {
        switch viewModel.cameraState {
        case .readyTakingImage:
            return .photo
        case .readyRecordingVideo:
            return .video
        case .recordingVideo:
            return .recording
        }
    }
    
    private func capture() {
        switch viewModel.cameraState {
        case .readyTakingImage:
            viewModel.capturePhoto()
        case .readyRecordingVideo:
            viewModel.startRecordingVideo()
        case .recordingVideo:
            viewModel.stopRecordingVideo()
        }
    }
    
    // MARK: - Mode selection
    
    private var modeSelector: some View {
        CameraModeSelectorView(selectedType: viewModel.cameraState.cameraType,
                               onSelect: viewModel.selectCameraType)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(modeSwipeGesture)
        .hiddenDuringRecording(viewModel.cameraState.isRecording)
    }
    
    /// Swiping across the toggle moves between modes, matching the swipe over the viewfinder.
    private var modeSwipeGesture: some Gesture {
        DragGesture(minimumDistance: .smallMedium)
            .onEnded { value in
                guard let direction = CameraSwipeDirection(translationX: value.translation.width,
                                                           translationY: value.translation.height) else { return }
                viewModel.selectCameraType(direction.cameraType)
            }
    }
    
    // MARK: - Navigation
    
    private func openGallery() {
        viewModel.hideMenu()
        navigateTo(destination: getFileListView())
    }
    
    private func getFileListView() -> FileListView {
        FileListView(mainAppModel: viewModel.mainAppModel,
                     filterType: .photoVideo,
                     title: LocalizableCamera.appBar.localized,
                     fileListType: .cameraGallery)
    }
    
}


private struct CameraStatusChip: View {
    
    let title: String
    let isOn: Bool
    var rotation = CameraControlRotation()
    
    var body: some View {
        CustomText(title,
                   style: .subheading2Style,
                   alignment: .center,
                   color: Styles.Colors.backgroundGrey1)
        .padding(.horizontal, .small)
        .padding(.vertical, .tiny)
        .background(Capsule().fill(isOn ? Styles.Colors.yellowWhite : Color.white))
        .rotate(rotation)
    }
}

struct CameraControlsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(state: .readyTakingImage).previewDisplayName("Photo")
            preview(state: .readyRecordingVideo).previewDisplayName("Video")
            preview(state: .recordingVideo).previewDisplayName("Recording")
        }
    }
    
    private static func preview(state: CameraState) -> some View {
        CameraControlsView(viewModel: CameraViewModel.stub(state: state))
            .background(Color.gray)
    }
}

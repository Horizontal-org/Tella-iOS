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
    @State private var isZoomDialExpanded = false
    @State private var isPreviewZooming = false
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geometry in
            let layout = CameraViewfinderLayout(bounds: CGRect(origin: .zero, size: geometry.size),
                                                aspectRatio: previewAspectRatio,
                                                safeAreaInsets: UIEdgeInsets(top: geometry.safeAreaInsets.top,
                                                                             left: geometry.safeAreaInsets.leading,
                                                                             bottom: geometry.safeAreaInsets.bottom,
                                                                             right: geometry.safeAreaInsets.trailing))
            
            ZStack(alignment: .topLeading) {
                cameraPreview(in: layout)
                
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { isZoomDialExpanded = false }
                    .allowsHitTesting(isZoomDialExpanded)
                
                headerControls
                    .frame(width: layout.headerFrame.width, height: layout.headerFrame.height)
                    .contentShape(Rectangle())
                    .simultaneousGesture(zoomDismissalGesture)
                    .position(x: layout.headerFrame.midX, y: layout.headerFrame.midY)
                
                recordingIndicator(previewFrame: layout.previewFrame,
                                   visiblePreviewTop: max(layout.headerFrame.maxY,
                                                          layout.previewFrame.minY))
                
                viewfinderOverlays
                    .cameraFrame(layout.optionsFrame)
                
                if showsZoomDialBackground {
                    CameraZoomDialBackground(zoomFrame: layout.zoomDialFrame,
                                             bottomEdge: layout.zoomDialBackgroundBottom)
                    .ignoresSafeArea(edges: .bottom)
                }
                
                captureControls
                    .contentShape(Rectangle())
                    .simultaneousGesture(zoomDismissalGesture)
                    .cameraFrame(layout.shutterFrame)
                
                modeSelector
                    .simultaneousGesture(zoomDismissalGesture)
                    .cameraFrame(layout.modeFrame)
                
                if !showsBottomMenu {
                    previewControls(zoomFrame: layout.zoomFrame,
                                    dialFrame: layout.zoomDialFrame,
                                    interactionFrame: layout.optionsFrame)
                }
            }
            .animation(.easeInOut(duration: CameraStyle.Animations.aspectRatio),
                       value: previewAspectRatio)
        }
        .background(Styles.Colors.backgroundGrey1.ignoresSafeArea())
        .buttonStyle(.plain)
        .disabled(viewModel.isRecordingTransitioning)
        .allowsHitTesting(!viewModel.isFlippingCamera)
        .onAppear {
            orientationHelper.startDeviceOrientationNotifier()
        }
        .onDisappear {
            isZoomDialExpanded = false
            orientationHelper.stopDeviceOrientationNotifier()
        }
        .onChange(of: showsBottomMenu) { isShowing in
            if isShowing { isZoomDialExpanded = false }
        }
        .onChange(of: viewModel.isFlippingCamera) { isFlipping in
            if isFlipping { isZoomDialExpanded = false }
        }
        .onChange(of: previewAspectRatio) { _ in
            isZoomDialExpanded = false
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
    
    private var showsZoomDialBackground: Bool {
        let range = CameraZoomScale(range: viewModel.availableZoomRange).range
        return isZoomDialExpanded && !showsBottomMenu && !viewModel.isFlippingCamera
        && range.lowerBound < range.upperBound
    }
    
    // MARK: - Preview
    
    /// The capture layer stays on the 3:4 canvas. Photo and video only scale and clip it,
    /// so the live image eases instead of restarting with the viewfinder.
    private func cameraPreview(in layout: CameraViewfinderLayout) -> some View {
        let visible = layout.previewFrame
        let source = viewModel.usesVideoPreset ? visible : layout.sourceFrame
        let scale = previewFillScale(source: source.size, visible: visible.size)
        
        return ZStack {
            CameraPreview(session: viewModel.session,
                          gridIsOn: false,
                          isFlipping: viewModel.isFlippingCamera)
            .frame(width: max(source.width, 1), height: max(source.height, 1))
            .scaleEffect(scale)
            .allowsHitTesting(false)
            
            if viewModel.gridIsOn {
                CameraPreviewGrid()
                    .allowsHitTesting(false)
            }
        }
        .frame(width: max(visible.width, 1), height: max(visible.height, 1))
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture(perform: viewModel.hideMenu)
        .simultaneousGesture(previewSwipeGesture)
        .simultaneousGesture(previewZoomGesture)
        .cameraFlipBlur(viewModel.isFlippingCamera)
        .position(x: visible.midX, y: visible.midY)
    }
    
    private func previewFillScale(source: CGSize, visible: CGSize) -> CGFloat {
        guard source.width > 0, source.height > 0 else { return 1 }
        return max(visible.width / source.width, visible.height / source.height)
    }
    
    private var previewZoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if !isPreviewZooming {
                    isPreviewZooming = true
                    viewModel.startZoom()
                }
                viewModel.zoom(by: scale)
            }
            .onEnded { _ in
                isPreviewZooming = false
            }
    }
    
    private var previewSwipeGesture: some Gesture {
        DragGesture(minimumDistance: CameraSwipeDirection.threshold)
            .onEnded { value in
                guard !isPreviewZooming,
                      let direction = CameraSwipeDirection(translationX: value.translation.width,
                                                           translationY: value.translation.height) else { return }
                viewModel.selectCameraType(direction.cameraType)
            }
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
    
    private func previewControls(zoomFrame: CGRect, dialFrame: CGRect, interactionFrame: CGRect) -> some View {
        CameraPreviewControlsView(zoomLevels: viewModel.availableZoomLevels,
                                  zoomLenses: viewModel.availableZoomLenses,
                                  zoomFactor: viewModel.currentZoomFactor,
                                  zoomRange: viewModel.availableZoomRange,
                                  zoomFrame: zoomFrame,
                                  dialFrame: dialFrame,
                                  interactionFrame: interactionFrame,
                                  isZoomDialExpanded: $isZoomDialExpanded,
                                  isRecording: viewModel.cameraState.isRecording,
                                  isFlipping: viewModel.isFlippingCamera,
                                  rotation: rotation,
                                  onZoomChanged: viewModel.setZoomFactor,
                                  onSelectZoomLevel: viewModel.setZoom,
                                  onMoreOptions: viewModel.toggleMoreActions)
    }
    
    private var zoomDismissalGesture: some Gesture {
        TapGesture().onEnded { isZoomDialExpanded = false }
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


// MARK: - Preview grid

private struct CameraPreviewGrid: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                for fraction in [CGFloat(1) / 3, CGFloat(2) / 3] {
                    path.move(to: CGPoint(x: width * fraction, y: 0))
                    path.addLine(to: CGPoint(x: width * fraction, y: height))
                    path.move(to: CGPoint(x: 0, y: height * fraction))
                    path.addLine(to: CGPoint(x: width, y: height * fraction))
                }
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}

// MARK: - Status chip

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

// MARK: - Previews

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

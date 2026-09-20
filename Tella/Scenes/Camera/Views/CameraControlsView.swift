//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import SwiftUI

struct CameraControlsView: View {
    // MARK: - Public properties
    @ObservedObject var cameraViewModel: CameraViewModel
    @ObservedObject var model: CameraModel
    @Binding var showingCameraView : Bool
    @Binding var gridIsOn: Bool
    @Binding var cameraState: CameraState
    
    // MARK: - Private properties
    
    private static let modeSwipeThreshold: CGFloat = 40
    
    @State private var deviceOrientation : UIDeviceOrientation = UIDevice.current.orientation
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            cameraHeaderView()
            
            Spacer(minLength: 0)
                .allowsHitTesting(false)
            
            viewfinderControls
            
            bottomBar
        }
        .onAppear {
            DeviceOrientationHelper().startDeviceOrientationNotifier { deviceOrientation in
                self.deviceOrientation = deviceOrientation
                shouldAnimate = true
            }
        }
        .onReceive(cameraViewModel.mainAppModel.$shouldSaveCurrentData) { value in
            if(value && cameraState == .recordingVideo) {
                stopRecordingVideo()
            }
        }
    }
    
    private var rotation: CameraControlRotation {
        CameraControlRotation(deviceOrientation: deviceOrientation,
                              shouldAnimate: shouldAnimate)
    }
    
    // MARK: - Header
    
    private func cameraHeaderView() -> some View {
        HStack(spacing: 0) {
            closeButton
            Spacer(minLength: 0)
            flashButton
            gridButton
        }
        .frame(height: .large)
        .background(Styles.Colors.backgroundGrey1.ignoresSafeArea(edges: .top))
    }
    
    @ViewBuilder
    var closeButton: some View {
        if !cameraState.isRecording {
            Button {
                cameraViewModel.dismissCamera(showingCameraView: $showingCameraView)
                model.stopRunningCaptureSession()
            } label: {
                Image(.close)
                    .padding(.normal)
            }
            .rotate(rotation)
        }
    }
    
    var flashButton: some View {
        Button {
            model.setFlashMode(model.flashMode.next)
        } label: {
            flashIcon
                .padding(.normal)
        }
        .disabled(!model.isFlashAvailable)
        .opacity(model.isFlashAvailable ? 1 : 0.4)
        .rotate(rotation)
    }
    
    @ViewBuilder
    private var flashIcon: some View {
        switch model.flashMode {
        case .auto:
            Image(.cameraFlashAuto)
        case .on:
            Image(.cameraFlashOn)
        case .off:
            Image(.cameraFlashOff)
        }
    }
    
    var gridButton: some View {
        Button {
            gridIsOn.toggle()
        } label: {
            Image(gridIsOn ? .cameraGridOn : .cameraGridOff)
                .padding(.normal)
        }
        
        .rotate(rotation)
        .accessibilityLabel(gridIsOn
                            ? LocalizableCamera.hideGrid.localized
                            : LocalizableCamera.showGrid.localized)
    }
    
    // MARK: - Viewfinder controls
    
    private var viewfinderControls: some View {
        CameraViewfinderControlsView(zoomLevels: model.availableZoomLevels,
                                     zoomFactor: model.currentZoomFactor,
                                     recordingTime: cameraState.isRecording
                                     ? cameraViewModel.formattedCurrentTime
                                     : nil,
                                     rotation: rotation,
                                     onSelectZoomLevel: { model.setZoom(to: $0) },
                                     onMoreOptions: moreOptionsTapped)
    }
    
    // MARK: - Bottom bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            
            controlRow
            
            modeSelector
            
        }
        .background(Styles.Colors.backgroundGrey1.ignoresSafeArea(edges: .bottom))
    }
    
    private var controlRow: some View {
        HStack(spacing: 0) {
            
            galleryButton
            
            Spacer()
            
            shutterButton
            
            Spacer()
            
            flipCameraButton
        }
        .padding(.horizontal, .extraLarge)
        .frame(height: 85.adjusted)
    }
    
    /// The gallery and flip buttons stay in the layout while recording, so the shutter does not move.
    private var galleryButton: some View {
        CameraGalleryButton(file: cameraViewModel.lastImageOrVideoVaultFile,
                            rotation: rotation) {
            navigateTo(destination: getFileListView())
        }
        .hiddenDuringRecording(cameraState.isRecording)
    }
    
    private var shutterButton: some View {
        CameraShutterButton(mode: shutterMode) {
            switch cameraState {
            case .readyTakingImage:
                model.capturePhoto()
            case .readyRecordingVideo:
                startRecordingVideo()
            case .recordingVideo:
                stopRecordingVideo()
            }
        }
    }
    
    private var shutterMode: CameraShutterMode {
        switch cameraState {
        case .readyTakingImage:
            return .photo
        case .readyRecordingVideo:
            return .video
        case .recordingVideo:
            return .recording
        }
    }
    
    var flipCameraButton: some View {
        
        Button {
            model.toggleCameraType()
        } label: {
            ZStack {
                Image(.cameraFlipCamera)
            }
            .frame(width: .mediumIconSize,
                   height: .mediumIconSize)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
        }
        .rotate(rotation)
        .hiddenDuringRecording(cameraState.isRecording)
    }
    
    private var modeSelector: some View {
        CameraModeSelectorView(selectedType: cameraState.cameraType,
                               onSelect: selectCameraType)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(modeSwipeGesture)
        .hiddenDuringRecording(cameraState.isRecording)
    }
    
    /// Swiping across the toggle moves between modes, matching the swipe over the viewfinder.
    private var modeSwipeGesture: some Gesture {
        DragGesture(minimumDistance: .smallMedium)
            .onEnded { value in
                let translation = value.translation
                
                guard abs(translation.width) > Self.modeSwipeThreshold,
                      abs(translation.width) > abs(translation.height) else { return }
                
                selectCameraType(translation.width < 0 ? .image : .video)
            }
    }
    
    // MARK: - Actions
    
    func getFileListView() -> FileListView {
        FileListView(mainAppModel: cameraViewModel.mainAppModel,
                     filterType: .photoVideo,
                     title: LocalizableCamera.appBar.localized,
                     fileListType: .cameraGallery)
    }
    
    private func startRecordingVideo() {
        withAnimation(.easeInOut(duration: CameraStyle.Animations.recording)) {
            cameraState = .recordingVideo
        }
        model.startCaptureVideo()
        cameraViewModel.initialiseTimerRunning()
    }
    
    private func stopRecordingVideo() {
        withAnimation(.easeInOut(duration: CameraStyle.Animations.recording)) {
            cameraState = .readyRecordingVideo
        }
        model.startCaptureVideo()
        cameraViewModel.invalidateTimerRunning()
    }
    
    private func selectCameraType(_ cameraType: CameraType) {
        guard !cameraState.isRecording,
              cameraState.cameraType != cameraType else { return }
        
        withAnimation(.easeInOut(duration: CameraStyle.Animations.modeChange)) {
            cameraState = CameraState(cameraType: cameraType)
        }
        
        model.cameraType = cameraType
    }
    
    private func moreOptionsTapped() {
        // TODO: behaviour of the extra options button is still to be defined.
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
        CameraControlsView(cameraViewModel: CameraViewModel.stub(),
                           model: CameraModel.stub(),
                           showingCameraView: .constant(false),
                           gridIsOn: .constant(false),
                           cameraState: .constant(state))
        .background(Color.gray)
    }
}

private extension View {
    
    /// Keeps the control in the layout while recording so the shutter does not shift, then fades it out.
    func hiddenDuringRecording(_ isRecording: Bool) -> some View {
        self
            .opacity(isRecording ? 0 : 1)
            .disabled(isRecording)
            .animation(.easeInOut(duration: CameraStyle.Animations.recording),
                       value: isRecording)
    }
}

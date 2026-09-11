//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import SwiftUI

struct CameraControlsView: View {
    // MARK: - Public properties
    @ObservedObject var cameraViewModel: CameraViewModel
    @Binding var showingCameraView : Bool
    var sourceView : SourceView
    @Binding var gridIsOn: Bool
    @Binding var cameraState: CameraState
    
    var captureButtonAction: (() -> Void)
    var recordVideoAction: (() -> Void)
    var toggleCamera: (() -> Void)
    var selectCameraType: ((CameraType) -> Void)
    var updateFlashMode: ((CameraFlashMode) -> Void)
    var selectZoomLevel: ((CameraZoomLevel) -> Void)
    var moreOptionsAction: (() -> Void)
    var close: (() -> Void)
    var zoomFactor: CGFloat = 1.0
    var zoomLevels: [CameraZoomLevel] = []
    var flashMode: CameraFlashMode = .off
    var isFlashAvailable: Bool = true
    
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
                
                if sourceView == .tab {
                    cameraViewModel.mainAppModel.selectedTab = .home
                } else {
                    showingCameraView = false
                }
                
                close()
                
            } label: {
                Image(.close)
                    .padding(.normal)
            }
            .rotate(rotation)
        }
    }
    
    var flashButton: some View {
        Button {
            updateFlashMode(flashMode.next)
        } label: {
            flashIcon
                .padding(.normal)
        }
        .disabled(!isFlashAvailable)
        .opacity(isFlashAvailable ? 1 : 0.4)
        .rotate(rotation)
    }
    
    @ViewBuilder
    private var flashIcon: some View {
        switch flashMode {
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
        CameraViewfinderControlsView(zoomLevels: zoomLevels,
                                     zoomFactor: zoomFactor,
                                     recordingTime: cameraState.isRecording
                                     ? cameraViewModel.formattedCurrentTime
                                     : nil,
                                     rotation: rotation,
                                     onSelectZoomLevel: selectZoomLevel,
                                     onMoreOptions: moreOptionsAction)
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
                            .opacity(recordingChromeOpacity)
                            .disabled(cameraState.isRecording)
                            .animation(.easeInOut(duration: CameraStyle.Animations.recording),
                                       value: cameraState.isRecording)
    }
    
    private var shutterButton: some View {
        CameraShutterButton(mode: shutterMode) {
            switch cameraState {
            case .readyTakingImage:
                captureButtonAction()
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
        
        Button(action: toggleCamera) {
            ZStack {
                Image(.cameraFlipCamera)
            }
            .frame(width: .mediumIconSize,
                   height: .mediumIconSize)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
        }
        .rotate(rotation)
        .opacity(recordingChromeOpacity)
        .disabled(cameraState.isRecording)
        .animation(.easeInOut(duration: CameraStyle.Animations.recording),
                   value: cameraState.isRecording)
    }
    
    private var modeSelector: some View {
        CameraModeSelectorView(selectedType: cameraState.cameraType,
                               onSelect: selectCameraType)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(modeSwipeGesture)
        .opacity(recordingChromeOpacity)
        .disabled(cameraState.isRecording)
        .animation(.easeInOut(duration: CameraStyle.Animations.recording),
                   value: cameraState.isRecording)
    }
    
    private var recordingChromeOpacity: Double {
        cameraState.isRecording ? 0 : 1
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
        recordVideoAction()
        cameraViewModel.initialiseTimerRunning()
    }
    
    private func stopRecordingVideo() {
        withAnimation(.easeInOut(duration: CameraStyle.Animations.recording)) {
            cameraState = .readyRecordingVideo
        }
        recordVideoAction()
        cameraViewModel.invalidateTimerRunning()
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
                           showingCameraView: .constant(false),
                           sourceView: .tab,
                           gridIsOn: .constant(false),
                           cameraState: .constant(state),
                           captureButtonAction: {},
                           recordVideoAction: {},
                           toggleCamera: {},
                           selectCameraType: { _ in },
                           updateFlashMode: { _ in },
                           selectZoomLevel: { _ in },
                           moreOptionsAction: {},
                           close: {},
                           zoomFactor: 1,
                           zoomLevels: [CameraZoomLevel(factor: 0.5),
                                        CameraZoomLevel(factor: 1),
                                        CameraZoomLevel(factor: 2)])
        .background(Color.gray)
    }
}

private extension CameraFlashMode {
    var next: CameraFlashMode {
        switch self {
        case .auto:
            return .on
        case .on:
            return .off
        case .off:
            return .auto
        }
    }
}

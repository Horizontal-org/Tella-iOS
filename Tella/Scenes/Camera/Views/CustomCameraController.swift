//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine

final class CustomCameraController: UIViewController {
    
    static let shared = CustomCameraController()
    
    // MARK: - Private properties
    
    private var captureSession = AVCaptureSession()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureMovieFileOutput?
    
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Public properties
    
    weak var captureDelegate: AVCapturePhotoCaptureDelegate?
    weak var videoRecordingDelegate: AVCaptureFileOutputRecordingDelegate?
    
    var cameraType : CameraType = .image {
        didSet {
            stopRunningCaptureSession()
            releasePreview()
            cameraType == .video ? setupVideoInputOutput() : setupPhotoInputOutput()
        }
    }
    
    @Published var shouldShowPermission : Bool = false
    @Published var shouldCloseCamera : Bool = false
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        shouldCloseCamera = false
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        stopRunningCaptureSession()
        releasePreview()
     }

    // MARK: - Public functions
    
    func configurePreviewLayer(with frame: CGRect) {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer.frame = frame
        
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func stopRunningCaptureSession() {
        captureSession.stopRunning()
        shouldCloseCamera = false

    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let delegate = captureDelegate else {
            return
        }
        photoOutput?.capturePhoto(with: settings, delegate: delegate)
    }
    
    func startCaptureVideo(){
        if let videoOutput = videoOutput, videoOutput.isRecording {
            videoOutput.stopRecording()
        } else {
            let outFileUrl = createTempFileURL()
            guard let delegate = videoRecordingDelegate else {
                return
            }
            videoOutput?.startRecording(to: outFileUrl, recordingDelegate:delegate )
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
    
    func toggleFlash( ) {
        
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
    
    private func setup() {
        stopRunningCaptureSession()
        releasePreview()

        setupCaptureSession()
        cameraType == .video ? setupVideoInputOutput() : setupPhotoInputOutput()
    }
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    private func createTempFileURL() -> URL {
        let pathURL = URL(fileURLWithPath:NSTemporaryDirectory())
        
        return pathURL.appendingPathComponent("movie-\(Int(Date().timeIntervalSince1970)).mov")
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
        guard let photoOutput = videoOutput else { return }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
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
            shouldShowPermission = true
            self.shouldCloseCamera = false

        case .restricted:
            shouldShowPermission = true
            self.shouldCloseCamera = false

            return
        @unknown default:
            break
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

final class CustomCameraRepresentable: UIViewControllerRepresentable,ObservableObject {
    
    init(cameraFrame: CGRect, imageCompletion: @escaping ((UIImage, Data) -> Void), videoURLCompletion:@escaping ((URL) -> Void)) {
        self.cameraFrame = cameraFrame
        self.imageCompletion = imageCompletion
        self.videoURLCompletion = videoURLCompletion
    }
    
    var cameraFrame: CGRect
    var imageCompletion: ((UIImage,Data) -> Void)
    var videoURLCompletion: ((URL) -> Void)
    
    @Published var isRecording : Bool?
    
    @Published var imageData : Data?
    @Published var videoURL : URL?
    @Published var image : UIImage?
    @Published var shouldShowPermission : Bool = false
    @Published var shouldCloseCamera : Bool = false

    private var cancellable: Set<AnyCancellable> = []
    
    var cameraType : CameraType = .image {
        didSet {
            CustomCameraController.shared.cameraType = cameraType
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        CustomCameraController.shared.configurePreviewLayer(with: cameraFrame)
        CustomCameraController.shared.captureDelegate = context.coordinator
        CustomCameraController.shared.videoRecordingDelegate = context.coordinator
        
        CustomCameraController.shared.$shouldShowPermission.sink { value in
            DispatchQueue.main.async {
                self.shouldShowPermission = value
            }
        }.store(in: &cancellable)
        
        CustomCameraController.shared.$shouldCloseCamera.sink { value in
            DispatchQueue.main.async {
                self.shouldCloseCamera = value
            }
        }.store(in: &cancellable)
        
        return CustomCameraController.shared
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {}
    
    func checkCameraPermission() {
        CustomCameraController.shared.checkCameraPermission()
    }
    
    func takePhoto() {
        CustomCameraController.shared.takePhoto()
    }
    
    func startCaptureVideo() {
        CustomCameraController.shared.startCaptureVideo()
    }
    
    func toggleCameraType() {
        CustomCameraController.shared.toggleCameraType()
    }
    
    func toggleFlash()  {
        CustomCameraController.shared.toggleFlash()
    }
    
    func startRunningCaptureSession() {
        CustomCameraController.shared.startRunningCaptureSession()
    }
    
    func stopRunningCaptureSession() {
        CustomCameraController.shared.stopRunningCaptureSession()
    }
}

extension CustomCameraRepresentable {
    
    final class Coordinator: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
        
        private let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            if let imageData = photo.fileDataRepresentation() {
                guard let newImage = UIImage(data: imageData) else { return }
                parent.imageCompletion(newImage, imageData)
            }
        }
        
        func fileOutput(_ output: AVCaptureFileOutput,
                        didFinishRecordingTo outputFileURL: URL,
                        from connections: [AVCaptureConnection],
                        error: Error?) {
            
            parent.videoURLCompletion(outputFileURL)
            
            print("outputFileURL", outputFileURL)
            
            parent.isRecording = false
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
            parent.isRecording = true
        }
    }
}



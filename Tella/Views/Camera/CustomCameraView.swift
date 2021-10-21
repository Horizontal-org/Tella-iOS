//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import AVFoundation
 
struct CustomCameraView: View {
    
    @State var didTapCapture: Bool = false
    let completion: (UIImage?) -> ()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            CustomCameraRepresentable(didTapCapture: $didTapCapture, completion: completion)
            CaptureButtonView().onTapGesture {
                self.didTapCapture = true
            }
            .padding(.bottom, 100)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @Binding var didTapCapture: Bool
    let completion: (UIImage?) -> ()
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        if(self.didTapCapture) {
            cameraViewController.didTapRecord()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        
        let parent: CustomCameraRepresentable

        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            parent.didTapCapture = false
            parent.completion(photo.getImage())
        }
    }
}

extension AVCapturePhoto {
    
    func getImage() -> UIImage? {
        guard let cgImageRepresentation = cgImageRepresentation(),
            let orientationInt = metadata[String(kCGImagePropertyOrientation)] as? UInt32,
            let imageOrientation = UIImage.Orientation.orientation(fromCGOrientationRaw: orientationInt) else {
                return nil
        }

        let cgImage = cgImageRepresentation
        let image = UIImage(cgImage: cgImage,
                        scale: 1,
                        orientation: imageOrientation)
        return image
    }
    
}

extension UIImage.Orientation {

    init(_ cgOrientation: CGImagePropertyOrientation) {
        // we need to map with enum values becuase raw values do not match
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }

    /// Returns a UIImage.Orientation based on the matching cgOrientation raw value
    static func orientation(fromCGOrientationRaw cgOrientationRaw: UInt32) -> UIImage.Orientation? {
        var orientation: UIImage.Orientation?
        if let cgOrientation = CGImagePropertyOrientation(rawValue: cgOrientationRaw) {
            orientation = UIImage.Orientation(cgOrientation)
        } else {
            orientation = nil // only hit if improper cgOrientation is passed
        }
        return orientation
    }
}

class CustomCameraController: UIViewController {
    
    var image: UIImage?
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func didTapRecord() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
          mediaType: AVMediaType.video,
          position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDiscoverySession.devices {
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        self.currentCamera = self.backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            debugLog(error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}

struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "video").font(.largeTitle)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.red)
                    .scaleEffect(animationAmount)
                    .opacity(Double(2 - animationAmount))
                    .animation(Animation.easeOut(duration: 1)
                        .repeatForever(autoreverses: false))
        )
        .onAppear {
            self.animationAmount = 2
        }
    }
}

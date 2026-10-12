//
//  CameraSessionConfigurator.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 12/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation

enum CameraSessionConfigurator {
    
    private static let cameraDeviceTypes: [AVCaptureDevice.DeviceType] = [
        .builtInTripleCamera,
        .builtInDualWideCamera,
        .builtInDualCamera,
        .builtInWideAngleCamera
    ]
    
    @discardableResult
    static func addCameraInput(position: AVCaptureDevice.Position, to session: AVCaptureSession) -> Bool {
        guard let input = makeCameraInput(position: position),
              session.canAddInput(input) else { return false }

        session.addInput(input)
        return true
    }
    
    static func addAudioInput(to session: AVCaptureSession) {
        guard !hasAudioInput(in: session),
              let device = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else { return }
            session.addInput(input)
        } catch {
            debugLog("Unable to add the microphone: \(error.localizedDescription)")
        }
    }
    
    static func removeAudioInput(from session: AVCaptureSession) {
        for input in session.inputs {
            guard let deviceInput = input as? AVCaptureDeviceInput,
                  deviceInput.device.hasMediaType(.audio) else { continue }
            session.removeInput(deviceInput)
        }
    }
    
    static func hasAudioInput(in session: AVCaptureSession) -> Bool {
        session.inputs
            .compactMap { $0 as? AVCaptureDeviceInput }
            .contains { $0.device.hasMediaType(.audio) }
    }
    
    static func applyPreset(for type: CameraType, to session: AVCaptureSession) {
        let preset: AVCaptureSession.Preset = type == .video ? .high : .photo
        guard session.canSetSessionPreset(preset) else { return }
        session.sessionPreset = preset
    }
    
    @discardableResult
    static func toggleCamera(in session: AVCaptureSession) -> Bool {
        guard let currentInput = videoInput(in: session),
              let newInput = makeCameraInput(position: currentInput.device.position == .back ? .front : .back)
        else { return false }

        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.removeInput(currentInput)

        if session.canAddInput(newInput) {
            session.addInput(newInput)
            return true
        } else if session.canAddInput(currentInput) {
            session.addInput(currentInput)
        }
        return false
    }
    
    static func videoDevice(in session: AVCaptureSession) -> AVCaptureDevice? {
        videoInput(in: session)?.device
    }
    
    static func removeAllInputsAndOutputs(from session: AVCaptureSession) {
        for input in session.inputs {
            session.removeInput(input)
        }
        
        for output in session.outputs {
            session.removeOutput(output)
        }
    }
    
    private static func videoInput(in session: AVCaptureSession) -> AVCaptureDeviceInput? {
        session.inputs
            .compactMap { $0 as? AVCaptureDeviceInput }
            .first { $0.device.hasMediaType(.video) }
    }
    
    private static func makeCameraInput(position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        for deviceType in cameraDeviceTypes {
            guard let device = AVCaptureDevice.default(deviceType, for: .video, position: position) else { continue }
            do {
                return try AVCaptureDeviceInput(device: device)
            } catch {
                debugLog("Unable to create the camera input: \(error.localizedDescription)")
            }
        }
        return nil
    }
}

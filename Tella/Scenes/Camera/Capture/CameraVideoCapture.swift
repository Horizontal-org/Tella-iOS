//
//  CameraVideoCapture.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 12/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation
import CoreLocation

final class CameraVideoCapture: NSObject {

    // MARK: - Types

    struct Recording {
        let url: URL
        let warning: Error?
    }

    // MARK: - Stored properties

    private(set) var videoOutput: AVCaptureMovieFileOutput?

    var onRecordingStarted: (() -> Void)?

    var onRecordingFinished: ((Result<Recording, Error>) -> Void)?

    // MARK: - Computed properties

    var isRecording: Bool {
        videoOutput?.isRecording ?? false
    }
}

extension CameraVideoCapture {

    // MARK: - Session configuration

    func attach(to session: AVCaptureSession) {
        guard videoOutput == nil else { return }

        let videoOutput = AVCaptureMovieFileOutput()
        guard session.canAddOutput(videoOutput) else { return }

        session.addOutput(videoOutput)
        self.videoOutput = videoOutput
    }

    func detach(from session: AVCaptureSession) {
        guard let videoOutput else { return }
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        }
        session.removeOutput(videoOutput)
        self.videoOutput = nil
    }

    func reset() {
        if let videoOutput, videoOutput.isRecording {
            videoOutput.stopRecording()
        }
        videoOutput = nil
    }

    // MARK: - Recording requests

    @discardableResult
    func startRecording(
        orientation: AVCaptureVideoOrientation,
        location: CLLocation?
    ) -> Bool {
        guard let videoOutput, !videoOutput.isRecording,
              let connection = videoOutput.connection(with: .video),
              connection.isActive, connection.isEnabled else { return false }

        connection.videoOrientation = orientation

        videoOutput.metadata = []
        if let location {
            videoOutput.add(location: location)
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("movie-\(UUID().uuidString).\(FileExtension.mov)")
        videoOutput.startRecording(to: url, recordingDelegate: self)
        return true
    }

    func stopRecording() {
        videoOutput?.stopRecording()
    }
}

extension CameraVideoCapture: AVCaptureFileOutputRecordingDelegate {

    // MARK: - Recording delegate callbacks

    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        onRecordingStarted?()
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        let finishedSuccessfully = (error as NSError?)?.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as? NSNumber
        if let error, finishedSuccessfully?.boolValue != true {
            try? FileManager.default.removeItem(at: outputFileURL)
            onRecordingFinished?(.failure(error))
        } else {
            onRecordingFinished?(.success(Recording(url: outputFileURL, warning: error)))
        }
    }
}

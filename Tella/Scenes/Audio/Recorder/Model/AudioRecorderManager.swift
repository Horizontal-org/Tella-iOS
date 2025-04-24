//
//  AudioManager.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import AVFoundation

protocol AudioRecorderManager {
    func startRecording()
    func pauseRecording()
    func stopRecording(fileName:String)
    func discardRecord(audioChunks:[AVURLAsset]?)
    
    func playRecord()
    func pauseRecord()
}

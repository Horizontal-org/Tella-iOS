//
//  AudioManager.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

protocol AudioManager {
    func startRecording()
    func stopRecording()
    func saveRecord()
    func discardRecord()
    func resetRecorder()
}
